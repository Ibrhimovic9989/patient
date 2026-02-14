import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:clinic/presentation/patients/assign_therapist_screen.dart';
import 'package:clinic/presentation/patients/package_schedule_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  String? _clinicId;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      // Get clinic_id from current user (clinic admin)
      // For now, we'll need to get it from therapist or patient table
      // This is a placeholder - in production, clinic admin would have their own auth
      final userEmail = _supabase.auth.currentUser?.email;
      
      // Get clinic by owner email
      final clinicResponse = await _supabase
          .from('clinic')
          .select('id')
          .eq('owner_email', userEmail ?? '')
          .maybeSingle();

      if (clinicResponse == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _clinicId = clinicResponse['id'] as String;

      // Fetch patients from the clinic only
      // Note: Patients now select their own clinic during signup
      final patientsResponse = await _supabase
          .from('patient')
          .select('id, patient_name, email, phone, clinic_id, patient_package!left(id, package_id, status, package:package_id(name))')
          .eq('clinic_id', _clinicId!); // Only show patients who selected this clinic

      setState(() {
        _patients = List<Map<String, dynamic>>.from(patientsResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: $e')),
        );
      }
    }
  }

  Future<void> _assignTherapist(String patientId, String patientName) async {
    // Note: Patients now select their own clinic during signup
    // Clinic admin only assigns therapist to patients
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AssignTherapistScreen(
          patientId: patientId,
          patientName: patientName,
        ),
      ),
    );

    if (result == true) {
      _loadPatients(); // Refresh list
    }
  }

  Future<List<Map<String, dynamic>>> _loadPatientAssignments(String patientId) async {
    try {
      // Get active patient package
      final packageResponse = await _supabase
          .from('patient_package')
          .select('id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (packageResponse == null) {
        return [];
      }

      final patientPackageId = packageResponse['id'] as String;

      // Fetch assignments with therapy and therapist names
      final assignmentsResponse = await _supabase
          .from('patient_therapist_assignment')
          .select('''
            therapy_type_id,
            therapist_id,
            therapy:therapy_type_id(name),
            therapist:therapist_id(name)
          ''')
          .eq('patient_id', patientId)
          .eq('patient_package_id', patientPackageId)
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(assignmentsResponse).map((assignment) {
        final therapy = assignment['therapy'] as Map<String, dynamic>?;
        final therapist = assignment['therapist'] as Map<String, dynamic>?;
        return {
          'therapy_name': therapy?['name'] ?? 'Unknown',
          'therapist_name': therapist?['name'] ?? 'Unassigned',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _scheduleSessions(String patientId, String patientName) async {
    // Check if patient has active package
    final packageResponse = await _supabase
        .from('patient_package')
        .select('id, package_id')
        .eq('patient_id', patientId)
        .eq('status', 'active')
        .maybeSingle();

    if (packageResponse == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient does not have an active package. Please assign a package first.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Check if package has therapy details configured
    final packageId = packageResponse['package_id'] as String;
    final therapyDetailsCheck = await _supabase
        .from('package_therapy_details')
        .select('id')
        .eq('package_id', packageId)
        .limit(1)
        .maybeSingle();

    if (therapyDetailsCheck == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package does not have therapy details configured. Please configure therapy types for this package first.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PackageScheduleScreen(
          patientId: patientId,
          patientName: patientName,
        ),
      ),
    );

    if (result == true) {
      _loadPatients(); // Refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No patients found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPatients,
                  child: ListView.builder(
                    itemCount: _patients.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      final patientId = patient['id'] as String;
                      final patientPackages = patient['patient_package'] as List<dynamic>?;
                      final hasActivePackage = patientPackages?.any((p) => p['status'] == 'active') ?? false;
                      final activePackage = hasActivePackage 
                          ? patientPackages?.firstWhere((p) => p['status'] == 'active')
                          : null;
                      final packageName = activePackage?['package']?['name'] as String?;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Text(patient['patient_name'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patient['email'] ?? ''),
                              if (packageName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Package: $packageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasActivePackage)
                                IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _scheduleSessions(
                                    patientId,
                                    patient['patient_name'] as String,
                                  ),
                                  tooltip: 'Schedule Sessions',
                                ),
                              IconButton(
                                icon: const Icon(Icons.person_add),
                                onPressed: () => _assignTherapist(
                                  patientId,
                                  patient['patient_name'] as String,
                                ),
                                tooltip: 'Assign/Edit Therapists',
                              ),
                            ],
                          ),
                          children: [
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: _loadPatientAssignments(patientId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final assignments = snapshot.data ?? [];
                                if (assignments.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No therapists assigned',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Therapy Assignments:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...assignments.map((assignment) {
                                        final therapyName = assignment['therapy_name'] as String? ?? 'Unknown';
                                        final therapistName = assignment['therapist_name'] as String? ?? 'Unassigned';
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.medical_services,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '$therapyName: $therapistName',
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
