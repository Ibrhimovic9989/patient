import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignClinicToPatientScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AssignClinicToPatientScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AssignClinicToPatientScreen> createState() => _AssignClinicToPatientScreenState();
}

class _AssignClinicToPatientScreenState extends State<AssignClinicToPatientScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _clinics = [];
  bool _isLoading = true;
  String? _selectedClinicId;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    try {
      // Get all active clinics
      final clinicsResponse = await _supabase
          .from('clinic')
          .select('id, name, email, is_active')
          .eq('is_active', true);

      setState(() {
        _clinics = List<Map<String, dynamic>>.from(clinicsResponse);
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

  Future<void> _assignClinic() async {
    if (_selectedClinicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clinic')),
      );
      return;
    }

    setState(() {
      _isAssigning = true;
    });

    try {
      await _supabase
          .from('patient')
          .update({'clinic_id': _selectedClinicId})
          .eq('id', widget.patientId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient assigned to clinic successfully')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning clinic: $e')),
        );
      }
    } finally {
      setState(() {
        _isAssigning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Clinic'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign clinic to ${widget.patientName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_clinics.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_hospital_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No clinics available',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _clinics.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final clinic = _clinics[index];
                      final isSelected = _selectedClinicId == clinic['id'];

                      return Card(
                        elevation: isSelected ? 4 : 1,
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : null,
                        child: RadioListTile<String>(
                          title: Text(
                            clinic['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(clinic['email'] ?? ''),
                          value: clinic['id'] as String,
                          groupValue: _selectedClinicId,
                          onChanged: (value) {
                            setState(() {
                              _selectedClinicId = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isAssigning || _selectedClinicId == null
                      ? null
                      : _assignClinic,
                  child: _isAssigning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Assign Clinic'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
