import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class PackageScheduleScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PackageScheduleScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PackageScheduleScreen> createState() => _PackageScheduleScreenState();
}

class _PackageScheduleScreenState extends State<PackageScheduleScreen> {
  final _supabase = Supabase.instance.client;
  
  Map<String, dynamic>? _patientPackage;
  List<Map<String, dynamic>> _therapyDetails = [];
  Map<String, Set<int>> _selectedDays = {}; // therapy_type_id -> Set of day numbers
  Map<String, TimeOfDay> _selectedTimes = {}; // therapy_type_id -> TimeOfDay
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<int> _dayNumbers = [0, 1, 2, 3, 4, 5, 6]; // 0=Sunday, 1=Monday, etc.

  @override
  void initState() {
    super.initState();
    _loadPackageData();
  }

  Future<void> _loadPackageData() async {
    try {
      // Fetch active patient package
      final packageResponse = await _supabase
          .from('patient_package')
          .select('''
            *,
            package:package_id(
              id,
              name,
              validity_days
            )
          ''')
          .eq('patient_id', widget.patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (packageResponse == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No active package found for this patient')),
          );
          Navigator.pop(context);
        }
        return;
      }

      _patientPackage = packageResponse as Map<String, dynamic>;
      final packageId = _patientPackage!['package_id'] as String;

      // Fetch therapy details for this package
      final therapyDetailsResponse = await _supabase
          .from('package_therapy_details')
          .select('*')
          .eq('package_id', packageId);
      
      print('DEBUG: Package ID: $packageId');
      print('DEBUG: Therapy Details Count: ${therapyDetailsResponse.length}');

      final therapyDetailsList = List<Map<String, dynamic>>.from(therapyDetailsResponse);
      
      // Fetch therapy names separately for each therapy type
      final therapyTypeIds = therapyDetailsList
          .map((d) => d['therapy_type_id'] as String)
          .whereType<String>()
          .toSet()
          .toList();
      
      Map<String, String> therapyNamesMap = {};
      if (therapyTypeIds.isNotEmpty) {
        // Fetch all therapies and filter in Dart
        final allTherapiesResponse = await _supabase
            .from('therapy')
            .select('id, name');
        
        for (final therapy in allTherapiesResponse) {
          final therapyId = therapy['id'] as String;
          if (therapyTypeIds.contains(therapyId)) {
            therapyNamesMap[therapyId] = therapy['name'] as String;
          }
        }
      }
      
      // Add therapy names to details
      for (final detail in therapyDetailsList) {
        final therapyTypeId = detail['therapy_type_id'] as String;
        detail['therapy'] = {
          'id': therapyTypeId,
          'name': therapyNamesMap[therapyTypeId] ?? 'Unknown Therapy',
        };
      }
      
      if (therapyDetailsList.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No therapy details found for this package. Please ensure the package has therapy types configured.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
      
      // Fetch existing schedule configs if any
      final patientPackageId = _patientPackage!['id'] as String;
      final existingConfigsResponse = await _supabase
          .from('package_schedule_config')
          .select('*')
          .eq('patient_package_id', patientPackageId);
      
      final existingConfigs = List<Map<String, dynamic>>.from(existingConfigsResponse);
      final configMap = <String, Map<String, dynamic>>{};
      for (final config in existingConfigs) {
        final therapyTypeId = config['therapy_type_id'] as String;
        configMap[therapyTypeId] = config;
      }
      
      setState(() {
        _therapyDetails = therapyDetailsList;
        _isLoading = false;
        
        // Initialize selected days and times (load from existing config if available)
        for (final detail in _therapyDetails) {
          final therapyTypeId = detail['therapy_type_id'] as String;
          final existingConfig = configMap[therapyTypeId];
          
          if (existingConfig != null) {
            // Load existing configuration
            final daysOfWeek = existingConfig['days_of_week'] as List?;
            if (daysOfWeek != null) {
              _selectedDays[therapyTypeId] = daysOfWeek.map((d) => d as int).toSet();
            } else {
              _selectedDays[therapyTypeId] = <int>{};
            }
            
            // Parse time from time_slot (HH:MM:SS format)
            final timeSlot = existingConfig['time_slot'] as String?;
            if (timeSlot != null) {
              final timeParts = timeSlot.split(':');
              if (timeParts.length >= 2) {
                final hour = int.tryParse(timeParts[0]) ?? 9;
                final minute = int.tryParse(timeParts[1]) ?? 0;
                _selectedTimes[therapyTypeId] = TimeOfDay(hour: hour, minute: minute);
              } else {
                _selectedTimes[therapyTypeId] = const TimeOfDay(hour: 9, minute: 0);
              }
            } else {
              _selectedTimes[therapyTypeId] = const TimeOfDay(hour: 9, minute: 0);
            }
          } else {
            // Initialize with defaults
            _selectedDays[therapyTypeId] = <int>{};
            _selectedTimes[therapyTypeId] = const TimeOfDay(hour: 9, minute: 0);
          }
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading package data: $e')),
        );
      }
    }
  }

  void _toggleDay(String therapyTypeId, int dayNumber) {
    setState(() {
      final days = _selectedDays[therapyTypeId] ?? <int>{};
      if (days.contains(dayNumber)) {
        days.remove(dayNumber);
      } else {
        days.add(dayNumber);
      }
      _selectedDays[therapyTypeId] = days;
    });
  }

  Future<void> _selectTime(String therapyTypeId) async {
    final initialTime = _selectedTimes[therapyTypeId] ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (picked != null) {
      setState(() {
        _selectedTimes[therapyTypeId] = picked;
      });
    }
  }

  bool _validateSchedule() {
    for (final detail in _therapyDetails) {
      final therapyTypeId = detail['therapy_type_id'] as String;
      final frequency = detail['frequency_per_week'] as int? ?? 0;
      final selectedDaysCount = _selectedDays[therapyTypeId]?.length ?? 0;
      
      if (selectedDaysCount != frequency) {
        final therapy = detail['therapy'] as Map<String, dynamic>?;
        final therapyName = therapy?['name'] ?? 'Unknown';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$therapyName: Please select exactly $frequency day(s) per week'),
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _saveSchedule() async {
    if (!_validateSchedule()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final patientPackageId = _patientPackage!['id'] as String;
      final userId = _supabase.auth.currentUser?.id;

      // Save schedule configs for each therapy type
      for (final detail in _therapyDetails) {
        final therapyTypeId = detail['therapy_type_id'] as String;
        final selectedDays = _selectedDays[therapyTypeId]?.toList() ?? [];
        final selectedTime = _selectedTimes[therapyTypeId] ?? const TimeOfDay(hour: 9, minute: 0);
        
        // Convert TimeOfDay to TIME format (HH:MM:SS)
        final timeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00';

        // Upsert schedule config
        await _supabase
            .from('package_schedule_config')
            .upsert({
              'patient_package_id': patientPackageId,
              'therapy_type_id': therapyTypeId,
              'days_of_week': selectedDays,
              'time_slot': timeString,
              'created_by': userId,
            }, onConflict: 'patient_package_id,therapy_type_id');
      }

      // Call Edge Function to generate sessions
      // Supabase client automatically includes JWT token in Authorization header
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('User not authenticated. Please sign in again.');
      }
      
      // Don't manually add Authorization - Supabase client does this automatically
      final response = await _supabase.functions.invoke(
        'schedule-package-sessions',
        body: {'patient_package_id': patientPackageId},
      );

      final sessionsCreated = response.data['sessions_created'] as int? ?? 0;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Schedule saved! $sessionsCreated sessions created.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $e')),
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule Sessions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final package = _patientPackage!['package'] as Map<String, dynamic>?;
    final packageName = package?['name'] ?? 'Unknown Package';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Sessions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient and Package Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient: ${widget.patientName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Package: $packageName',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Check if therapy details exist
            if (_therapyDetails.isEmpty)
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.orange[700]),
                      const SizedBox(height: 16),
                      const Text(
                        'No therapy types found for this package',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please ensure the package has therapy details configured in the package_therapy_details table.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Show count of therapy types
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Configure schedule for ${_therapyDetails.length} therapy type(s):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Therapy Types Schedule
              ..._therapyDetails.map((detail) {
              final therapy = detail['therapy'] as Map<String, dynamic>?;
              final therapyName = therapy?['name'] ?? 'Unknown Therapy';
              final therapyTypeId = detail['therapy_type_id'] as String;
              final frequency = detail['frequency_per_week'] as int? ?? 0;
              final sessionCount = detail['session_count'] as int? ?? 0;
              final duration = detail['session_duration_minutes'] as int? ?? 0;
              final selectedDays = _selectedDays[therapyTypeId] ?? <int>{};
              final selectedTime = _selectedTimes[therapyTypeId] ?? const TimeOfDay(hour: 9, minute: 0);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              therapyName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text('$frequency x/week'),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$sessionCount sessions • $duration minutes each',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),

                      // Days Selection
                      Text(
                        'Select $frequency day(s):',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _dayNumbers.map((dayNum) {
                          final isSelected = selectedDays.contains(dayNum);
                          return FilterChip(
                            label: Text(_dayNames[dayNum]),
                            selected: isSelected,
                            onSelected: (selected) => _toggleDay(therapyTypeId, dayNum),
                            selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                            checkmarkColor: AppTheme.primaryColor,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Time Selection
                      Row(
                        children: [
                          const Text(
                            'Time: ',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectTime(therapyTypeId),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ],
                      ),

                      // Validation indicator
                      if (selectedDays.length != frequency)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select exactly $frequency day(s)',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            ],

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveSchedule,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Schedule & Generate Sessions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
