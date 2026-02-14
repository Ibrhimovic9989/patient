import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TherapistsScreen extends StatefulWidget {
  const TherapistsScreen({super.key});

  @override
  State<TherapistsScreen> createState() => _TherapistsScreenState();
}

class _TherapistsScreenState extends State<TherapistsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _therapists = [];
  bool _isLoading = true;
  String? _clinicId;

  @override
  void initState() {
    super.initState();
    _loadTherapists();
  }

  Future<void> _loadTherapists() async {
    try {
      // Get clinic_id from current user (clinic admin)
      final userEmail = _supabase.auth.currentUser?.email;
      
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

      // Fetch therapists from the clinic
      final therapistsResponse = await _supabase
          .from('therapist')
          .select('id, name, email, phone, specialisation, approved, clinic_id')
          .eq('clinic_id', _clinicId!);

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
          SnackBar(content: Text('Error loading therapists: $e')),
        );
      }
    }
  }

  // Note: Therapists now select their own clinic during signup
  // Clinic admin only needs to approve therapists

  Future<void> _approveTherapist(String therapistId) async {
    try {
      await _supabase
          .from('therapist')
          .update({'approved': true})
          .eq('id', therapistId);

      _loadTherapists(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Therapist approved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving therapist: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapists'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _therapists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No therapists found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTherapists,
                  child: ListView.builder(
                    itemCount: _therapists.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final therapist = _therapists[index];
                      final hasClinic = therapist['clinic_id'] != null;
                      final isApproved = therapist['approved'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(therapist['name'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(therapist['email'] ?? ''),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    hasClinic ? Icons.check_circle : Icons.pending,
                                    size: 16,
                                    color: hasClinic ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hasClinic
                                        ? 'Assigned to clinic'
                                        : 'No clinic assigned',
                                    style: TextStyle(
                                      color: hasClinic ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (!isApproved) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Pending Approval',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: !isApproved
                              ? IconButton(
                                  icon: const Icon(Icons.check),
                                  onPressed: () => _approveTherapist(
                                    therapist['id'] as String,
                                  ),
                                  tooltip: 'Approve Therapist',
                                  color: Colors.green,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
