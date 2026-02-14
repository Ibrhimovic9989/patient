import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignTherapistScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const AssignTherapistScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<AssignTherapistScreen> createState() => _AssignTherapistScreenState();
}

class _AssignTherapistScreenState extends State<AssignTherapistScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _therapists = [];
  List<Map<String, dynamic>> _therapyTypes = [];
  Map<String, String?> _selectedTherapists = {}; // therapy_type_id -> therapist_id
  Map<String, String> _therapyTypeNames = {}; // therapy_type_id -> name
  bool _isLoading = true;
  bool _isSaving = false;
  String? _patientPackageId;
  String? _packageId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 1. Get patient's clinic_id
      final patientResponse = await _supabase
          .from('patient')
          .select('clinic_id')
          .eq('id', widget.patientId)
          .maybeSingle();

      if (patientResponse == null || patientResponse['clinic_id'] == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient not found or not assigned to a clinic')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final clinicId = patientResponse['clinic_id'] as String;

      // 2. Fetch patient's active package
      final packageResponse = await _supabase
          .from('patient_package')
          .select('package_id, id')
          .eq('patient_id', widget.patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (packageResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient does not have an active package')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _packageId = packageResponse['package_id'] as String;
      _patientPackageId = packageResponse['id'] as String;

      // 3. Fetch therapy types from package
      final therapyDetailsResponse = await _supabase
          .from('package_therapy_details')
          .select('therapy_type_id, therapy:therapy_type_id(name)')
          .eq('package_id', _packageId!);

      final therapyTypesList = List<Map<String, dynamic>>.from(therapyDetailsResponse);
      _therapyTypes = therapyTypesList;
      
      // Build therapy type name map
      for (final detail in therapyTypesList) {
        final therapyTypeId = detail['therapy_type_id'] as String;
        final therapy = detail['therapy'] as Map<String, dynamic>?;
        _therapyTypeNames[therapyTypeId] = therapy?['name'] ?? 'Unknown Therapy';
      }

      // 4. Fetch existing assignments
      final assignmentsResponse = await _supabase
          .from('patient_therapist_assignment')
          .select('therapy_type_id, therapist_id')
          .eq('patient_id', widget.patientId)
          .eq('patient_package_id', _patientPackageId!)
          .eq('is_active', true);

      for (final assignment in assignmentsResponse) {
        final therapyTypeId = assignment['therapy_type_id'] as String;
        final therapistId = assignment['therapist_id'] as String?;
        _selectedTherapists[therapyTypeId] = therapistId;
      }

      // 5. Fetch therapists from the same clinic
      final therapistsResponse = await _supabase
          .from('therapist')
          .select('id, name, email, specialisation, approved, offered_therapies')
          .eq('clinic_id', clinicId)
          .eq('approved', true);

      setState(() {
        _therapists = List<Map<String, dynamic>>.from(therapistsResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<bool> _validateTherapistForTherapyType(
      String therapistId, String therapyTypeId) async {
    try {
      // Get therapy type name from the ID
      final therapyTypeName = _therapyTypeNames[therapyTypeId];
      if (therapyTypeName == null) {
        return false;
      }
      
      final therapist = await _supabase
          .from('therapist')
          .select('offered_therapies')
          .eq('id', therapistId)
          .single();

      final offeredTherapies = List<String>.from(therapist['offered_therapies'] ?? []);
      // Compare with therapy type name, not ID (offered_therapies stores names)
      return offeredTherapies.contains(therapyTypeName);
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAssignments() async {
    if (_patientPackageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient package not found')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Save/update assignments for each therapy type
      for (final therapyType in _therapyTypes) {
        final therapyTypeId = therapyType['therapy_type_id'] as String;
        final selectedTherapistId = _selectedTherapists[therapyTypeId];

        if (selectedTherapistId == null) {
          // Deactivate existing assignment if no therapist selected
          await _supabase
              .from('patient_therapist_assignment')
              .update({'is_active': false})
              .eq('patient_id', widget.patientId)
              .eq('therapy_type_id', therapyTypeId)
              .eq('patient_package_id', _patientPackageId!);
          continue;
        }

        // Validate therapist offers this therapy type
        final isValid = await _validateTherapistForTherapyType(
            selectedTherapistId, therapyTypeId);
        if (!isValid) {
          final therapyTypeName = _therapyTypeNames[therapyTypeId] ?? 'Unknown';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Therapist does not offer $therapyTypeName. Please select a different therapist.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isSaving = false;
          });
          return;
        }

        // Check if assignment already exists
        final existing = await _supabase
            .from('patient_therapist_assignment')
            .select('id')
            .eq('patient_id', widget.patientId)
            .eq('therapy_type_id', therapyTypeId)
            .eq('patient_package_id', _patientPackageId!)
            .maybeSingle();

        if (existing != null) {
          // Update existing assignment
          await _supabase
              .from('patient_therapist_assignment')
              .update({
                'therapist_id': selectedTherapistId,
                'assigned_by': userId,
                'assigned_at': DateTime.now().toIso8601String(),
                'is_active': true,
              })
              .eq('id', existing['id']);
        } else {
          // Create new assignment
          await _supabase.from('patient_therapist_assignment').insert({
            'patient_id': widget.patientId,
            'therapist_id': selectedTherapistId,
            'therapy_type_id': therapyTypeId,
            'patient_package_id': _patientPackageId!,
            'assigned_by': userId,
            'is_active': true,
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Therapist assignments saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assignments: $e')),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  List<Map<String, dynamic>> _getTherapistsForTherapyType(String therapyTypeId) {
    // Get therapy type name from the ID
    final therapyTypeName = _therapyTypeNames[therapyTypeId];
    if (therapyTypeName == null) {
      return [];
    }
    
    return _therapists.where((therapist) {
      final offeredTherapies = List<String>.from(therapist['offered_therapies'] ?? []);
      // Compare with therapy type name, not ID (offered_therapies stores names)
      return offeredTherapies.contains(therapyTypeName);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Therapists'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _therapyTypes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No therapy types found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Patient package does not have therapy types configured',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assign therapists to ${widget.patientName}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select a therapist for each therapy type in the patient\'s package',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _therapyTypes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final therapyType =
                                _therapyTypes[index];
                            final therapyTypeId =
                                therapyType['therapy_type_id'] as String;
                            final therapyTypeName =
                                _therapyTypeNames[therapyTypeId] ?? 'Unknown Therapy';
                            final selectedTherapistId =
                                _selectedTherapists[therapyTypeId];
                            final availableTherapists =
                                _getTherapistsForTherapyType(therapyTypeId);

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      therapyTypeName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (availableTherapists.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'No therapists available for this therapy type',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    else
                                      DropdownButtonFormField<String>(
                                        value: selectedTherapistId,
                                        decoration: const InputDecoration(
                                          labelText: 'Select Therapist',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('None (Unassign)'),
                                          ),
                                          ...availableTherapists.map((therapist) {
                                            return DropdownMenuItem<String>(
                                              value: therapist['id'] as String,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    therapist['name'] ?? 'Unknown',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (therapist['specialisation'] != null)
                                                    Text(
                                                      therapist['specialisation'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedTherapists[therapyTypeId] = value;
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSaving ? null : _saveAssignments,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save Assignments'),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
