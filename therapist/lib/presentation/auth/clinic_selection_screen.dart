import 'package:flutter/material.dart';
import 'package:therapist/core/theme/theme.dart';
import 'package:therapist/provider/auth_provider.dart';
import 'package:therapist/presentation/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicSelectionScreen extends StatefulWidget {
  const ClinicSelectionScreen({super.key});

  @override
  State<ClinicSelectionScreen> createState() => _ClinicSelectionScreenState();
}

class _ClinicSelectionScreenState extends State<ClinicSelectionScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allClinics = [];
  List<Map<String, dynamic>> _filteredClinics = [];
  bool _isLoading = true;
  String? _selectedClinicId;
  bool _isSaving = false;
  String? _existingClinicId;
  Map<String, dynamic>? _existingClinic;
  bool _hasExistingClinic = false;

  @override
  void initState() {
    super.initState();
    _checkExistingClinic();
    _loadClinics();
    _searchController.addListener(_filterClinics);
  }

  Future<void> _checkExistingClinic() async {
    try {
      final therapistResponse = await _supabase
          .from('therapist')
          .select('clinic_id')
          .eq('id', _supabase.auth.currentUser!.id)
          .maybeSingle();

      if (therapistResponse != null && therapistResponse['clinic_id'] != null) {
        // User already has a clinic - show read-only view
        _existingClinicId = therapistResponse['clinic_id'] as String;
        _hasExistingClinic = true;
        
        // Load clinic details
        if (_existingClinicId != null) {
          final clinicResponse = await _supabase
              .from('clinic')
              .select('id, name, email, phone, address, country')
              .eq('id', _existingClinicId!)
              .maybeSingle();
          
          if (clinicResponse != null) {
            setState(() {
              _existingClinic = clinicResponse;
              _selectedClinicId = _existingClinicId; // Pre-select for display
            });
          }
        }
      }
    } catch (e) {
      // Continue to clinic selection if check fails
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    try {
      final response = await _supabase
          .from('clinic')
          .select('id, name, email, phone, address, country, is_active')
          .eq('is_active', true)
          .order('name');

      setState(() {
        _allClinics = List<Map<String, dynamic>>.from(response);
        _filteredClinics = _allClinics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading clinics: $e')),
        );
      }
    }
  }

  void _filterClinics() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClinics = _allClinics;
      } else {
        _filteredClinics = _allClinics.where((clinic) {
          final name = (clinic['name'] as String? ?? '').toLowerCase();
          final email = (clinic['email'] as String? ?? '').toLowerCase();
          final address = (clinic['address'] as String? ?? '').toLowerCase();
          return name.contains(query) ||
              email.contains(query) ||
              address.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _saveClinicSelection() async {
    if (_selectedClinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clinic')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Update therapist record with clinic_id
      await _supabase
          .from('therapist')
          .update({'clinic_id': _selectedClinicId})
          .eq('id', _supabase.auth.currentUser!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Clinic selected! Waiting for admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving clinic selection: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Clinic'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Clinic',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _hasExistingClinic
                      ? 'Your clinic assignment is locked. Only your clinic admin can change it. Contact your clinic admin if you need to switch clinics.'
                      : 'Select the clinic you work with. Your clinic admin will verify your request. Once selected, you cannot change it without admin approval.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_hasExistingClinic) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Clinic selection is locked. Contact your clinic admin to change.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  enabled: !_hasExistingClinic,
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or address...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClinics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_hospital_outlined,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'No clinics available'
                                  : 'No clinics found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                },
                                child: const Text('Clear search'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredClinics.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final clinic = _filteredClinics[index];
                          final isSelected = _selectedClinicId == clinic['id'];

                          return Card(
                            elevation: isSelected ? 4 : 1,
                            color: isSelected
                                ? Theme.of(context).primaryColor.withOpacity(0.1)
                                : null,
                            child: RadioListTile<String>(
                              title: Text(
                                clinic['name'] ?? 'Unknown Clinic',
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (clinic['email'] != null)
                                    Text(clinic['email']),
                                  if (clinic['address'] != null)
                                    Text(
                                      clinic['address'],
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  if (_hasExistingClinic && isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '✓ Your assigned clinic',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              value: clinic['id'] as String,
                              groupValue: _selectedClinicId,
                              onChanged: _hasExistingClinic ? null : (value) {
                                setState(() {
                                  _selectedClinicId = value;
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
          if (!_hasExistingClinic)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving || _selectedClinicId == null
                      ? null
                      : _saveClinicSelection,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Navigate to home screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text('Continue'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
