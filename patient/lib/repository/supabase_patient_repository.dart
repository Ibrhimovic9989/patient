import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:patient/core/result/result.dart';
import 'package:patient/presentation/appointments/models/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/entities/entities.dart';
import '../core/repository/repository.dart';
import '../model/task_model.dart';
import '../model/therapy_models/therapy_models.dart';
import '../model/package_models/package_models.dart';

class SupabasePatientRepository implements PatientRepository {

  SupabasePatientRepository({
    required SupabaseClient supabaseClient
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ActionResult> scheduleAppointment(PatientScheduleAppointmentEntity appointmentEntity) async {  
    try {
      final sessionMap = appointmentEntity.toMap();
      
      // Fetch patient's active package if exists
      final packageResponse = await _supabaseClient
          .from('patient_package')
          .select('package_id, id, clinic_id')
          .eq('patient_id', appointmentEntity.patientId)
          .eq('status', 'active')
          .maybeSingle();
      
      if (packageResponse != null) {
        sessionMap['package_id'] = packageResponse['package_id'];
        sessionMap['patient_package_id'] = packageResponse['id'];
        sessionMap['clinic_id'] = packageResponse['clinic_id'];
        // Note: therapy_type_id would need to be determined based on the service type
        // For now, we'll leave it null for manual bookings
      }
      
      await _supabaseClient.from('session')
      .insert(sessionMap);
      return ActionResultSuccess(
        data: 'Appointment scheduled successfully',
        statusCode: 200
      );
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500
      );
    }
  }
  
  @override
  Future<ActionResult> getTherapyGoals({required DateTime date, String? therapyTypeId}) async {
    try {
      final patientId = _supabaseClient.auth.currentUser!.id;
      
      // 1. Fetch patient's active package
      final activePackage = await _supabaseClient
          .from('patient_package')
          .select('package_id, id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (activePackage == null) {
        return ActionResultFailure(
          errorMessage: 'No active package found',
          statusCode: 404,
        );
      }

      final packageId = activePackage['package_id'] as String;
      final patientPackageId = activePackage['id'] as String;

      // 2. Get therapy types from package
      final therapyTypesResponse = await _supabaseClient
          .from('package_therapy_details')
          .select('therapy_type_id')
          .eq('package_id', packageId);

      if (therapyTypesResponse.isEmpty) {
        return ActionResultFailure(
          errorMessage: 'No therapy types found in package',
          statusCode: 404,
        );
      }

      // 3. Get assigned therapy types (only show goals for assigned therapists)
      final assignedTypesResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id, therapist_id, therapist:therapist_id(name, email, phone)')
          .eq('patient_id', patientId)
          .eq('is_active', true);

      if (assignedTypesResponse.isEmpty) {
        return ActionResultFailure(
          errorMessage: 'No therapists assigned for therapy types in your package',
          statusCode: 404,
        );
      }

      // 4. Get therapy type IDs that are both in package AND assigned
      final assignedTherapyTypeIds = assignedTypesResponse
          .map((a) => a['therapy_type_id'] as String)
          .toSet()
          .toList();

      // 5. If therapyTypeId filter is provided, validate it's in assigned types
      final filterTherapyTypeIds = therapyTypeId != null && assignedTherapyTypeIds.contains(therapyTypeId)
          ? [therapyTypeId]
          : assignedTherapyTypeIds;

      // 6. Fetch therapy goals filtered by assigned therapy types and date
      // Normalize the date to UTC by extracting only date components (year, month, day)
      // This ensures we're comparing dates correctly regardless of timezone
      final normalizedDate = date.isUtc 
          ? date 
          : DateTime.utc(date.year, date.month, date.day);
      final startOfDay = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 0, 0, 0);
      final endOfDay = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 23, 59, 59, 999);
      
      if (kDebugMode) {
        debugPrint('getTherapyGoals: Fetching goals for date: $date');
        debugPrint('getTherapyGoals: Date range (UTC): ${startOfDay.toIso8601String()} to ${endOfDay.toIso8601String()}');
        debugPrint('getTherapyGoals: Patient ID: $patientId');
        debugPrint('getTherapyGoals: Therapy type IDs: $filterTherapyTypeIds');
      }
      
      // Debug: Check if there are any goals at all for this patient (to verify RLS)
      final allGoalsCheck = await _supabaseClient
          .from('therapy_goal')
          .select('id, performed_on, therapy_type_id')
          .eq('patient_id', patientId)
          .limit(5);
      if (kDebugMode) {
        debugPrint('getTherapyGoals: Total goals for patient (RLS check): ${allGoalsCheck.length}');
        if (allGoalsCheck.isNotEmpty) {
          debugPrint('getTherapyGoals: Sample goals: ${allGoalsCheck.map((g) => '${g['performed_on']} (type: ${g['therapy_type_id']})').join(', ')}');
        }
      }
      
      final response = await _supabaseClient
          .from('therapy_goal')
          .select('*')
          .eq('patient_id', patientId)
          .filter('therapy_type_id', 'in', filterTherapyTypeIds)
          .gte('performed_on', startOfDay.toIso8601String())
          .lte('performed_on', endOfDay.toIso8601String());

      if (kDebugMode) {
        debugPrint('getTherapyGoals: Query returned ${response.length} goals for date range');
        if (response.isNotEmpty) {
          debugPrint('getTherapyGoals: First goal performed_on: ${response.first['performed_on']}');
          debugPrint('getTherapyGoals: First goal therapy_type_id: ${response.first['therapy_type_id']}');
        }
      }

      if (response.isEmpty) {
        if (kDebugMode) {
          debugPrint('getTherapyGoals: No goals found for date range - checking sessions');
        }
        // Don't return failure yet - check for sessions below
      }

      final filteredResponse = response;

      // 7. If no goals found, check for sessions on this date
      if (filteredResponse.isEmpty) {
        if (kDebugMode) {
          debugPrint('getTherapyGoals: No goals found, checking for sessions');
        }
        // Check for sessions on this date (use same date range)
        final sessionsResponse = await _supabaseClient
            .from('session')
            .select('''
              *,
              therapist:therapist_id(name, email, phone, specialisation),
              therapy:therapy_type_id(name)
            ''')
            .eq('patient_id', patientId)
            .gte('timestamp', startOfDay.toIso8601String())
            .lte('timestamp', endOfDay.toIso8601String())
            .filter('therapy_type_id', 'in', filterTherapyTypeIds);
        
        if (kDebugMode) {
          debugPrint('getTherapyGoals: Found ${sessionsResponse.length} sessions for date');
        }

        if (sessionsResponse.isNotEmpty) {
          // Return session info even if no goal exists - this allows showing session card
          // but tabs will show "No goals/observations/regressions noted today"
          final sessionData = sessionsResponse.first;
          final therapist = sessionData['therapist'] as Map<String, dynamic>?;
          final therapy = sessionData['therapy'] as Map<String, dynamic>?;
          
          // Get a default therapy goal structure and update with session data
          // We'll create a minimal goal model from session with empty arrays
          final defaultGoal = {
            'performed_on': sessionData['timestamp'],
            'therapist_id': sessionData['therapist_id'],
            'therapy_type_id': sessionData['therapy_type_id'],
            'goals': [],
            'observations': [],
            'regressions': [],
            'activities': [],
            'duration': sessionData['duration'] ?? 60,
            'therapy_mode': sessionData['mode'] ?? 1,
          };
          
          final therapyGoal = TherapyGoalModelMapper.fromMap(defaultGoal);
          
          return ActionResultSuccess(
            data: therapyGoal.copyWith(
              therapistName: therapist?['name'],
              therapistPhone: therapist?['phone'],
              therapistEmail: therapist?['email'],
              therapyType: therapy?['name'],
              therapyMode: sessionData['mode'] ?? 1,
              specialization: therapist?['specialisation'],
              duration: sessionData['duration'] ?? 60,
            ),
            statusCode: 200
          );
        }

        return ActionResultFailure(
          errorMessage: 'No therapy goals or sessions found for the specified date',
          statusCode: 404,
        );
      }

      // 8. Get therapist and therapy type info from goal
      final goalData = filteredResponse.first;
      final therapistId = goalData['therapist_id'] as String?;
      final goalTherapyTypeId = goalData['therapy_type_id'] as String?;

      final therapist = therapistId != null
          ? await _supabaseClient
              .from('therapist')
              .select('*')
              .eq('id', therapistId)
              .maybeSingle()
          : null;

      final therapyType = goalTherapyTypeId != null
          ? await _supabaseClient
              .from('therapy')
              .select('*')
              .eq('id', goalTherapyTypeId)
              .maybeSingle()
          : null;

      final therapyGoal = TherapyGoalModelMapper.fromMap(goalData);

      return ActionResultSuccess(
        data: therapyGoal.copyWith(
          therapistName: therapist?['name'],
          therapistPhone: therapist?['phone'],
          therapistEmail: therapist?['email'],
          therapyType: therapyType?['name'],
          therapyMode: goalData['therapy_mode'],
          specialization: therapist?['specialisation']
        ),
        statusCode: 200
      );
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> getTherapyTypesForPackage() async {
    try {
      final patientId = _supabaseClient.auth.currentUser!.id;
      
      // 1. Fetch patient's active package
      final activePackage = await _supabaseClient
          .from('patient_package')
          .select('package_id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (activePackage == null) {
        return ActionResultFailure(
          errorMessage: 'No active package found',
          statusCode: 404,
        );
      }

      final packageId = activePackage['package_id'] as String;

      // 2. Get therapy types from package with names
      final therapyTypesResponse = await _supabaseClient
          .from('package_therapy_details')
          .select('therapy_type_id, therapy:therapy_type_id(id, name)')
          .eq('package_id', packageId);

      if (therapyTypesResponse.isEmpty) {
        return ActionResultSuccess(data: <TherapyTypeModel>[], statusCode: 200);
      }

      // 3. Get assigned therapy types only
      final assignedTypesResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id')
          .eq('patient_id', patientId)
          .eq('is_active', true);

      final assignedTherapyTypeIds = assignedTypesResponse
          .map((a) => a['therapy_type_id'] as String)
          .toSet();

      // 4. Filter and map to models
      final therapyTypes = <TherapyTypeModel>[];
      for (final detail in therapyTypesResponse) {
        final therapyTypeId = detail['therapy_type_id'] as String;
        if (assignedTherapyTypeIds.contains(therapyTypeId)) {
          final therapy = detail['therapy'] as Map<String, dynamic>?;
          if (therapy != null) {
            therapyTypes.add(TherapyTypeModelMapper.fromMap(therapy));
          }
        }
      }

      return ActionResultSuccess(data: therapyTypes, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> getAppointmentsForDate(DateTime date) async {
    try {
      final patientId = _supabaseClient.auth.currentUser!.id;
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final response = await _supabaseClient
          .from('session')
          .select('''
            *,
            therapist:therapist_id(name, email, phone, specialisation),
            therapy:therapy_type_id(id, name)
          ''')
          .eq('patient_id', patientId)
          .gte('timestamp', startOfDay.toIso8601String())
          .lt('timestamp', endOfDay.toIso8601String())
          .order('timestamp', ascending: true);

      if (response.isEmpty) {
        return ActionResultSuccess(data: <Map<String, dynamic>>[], statusCode: 200);
      }

      final appointments = (response as List).map((session) {
        final sessionDate = DateTime.parse(session['timestamp']);
        final isCompleted = sessionDate.isBefore(DateTime.now());
        final therapist = session['therapist'] as Map<String, dynamic>?;
        final therapy = session['therapy'] as Map<String, dynamic>?;
        
        return {
          'id': session['id'],
          'timestamp': session['timestamp'],
          'duration': session['duration'] ?? 60,
          'status': session['status'] ?? 'pending',
          'is_consultation': session['is_consultation'] ?? false,
          'mode': session['mode'] ?? 1,
          'is_completed': isCompleted,
          'therapist_name': therapist?['name'],
          'therapist_specialization': therapist?['specialisation'],
          'therapy_type_name': therapy?['name'],
          'therapy_type_id': session['therapy_type_id'],
        };
      }).toList();

      return ActionResultSuccess(data: appointments, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> fetchAllAppointments() async {
    try {
      final response = await _supabaseClient.from('session').select('*').eq('patient_id', _supabaseClient.auth.currentUser!.id);
       if (response.isEmpty) {
        return ActionResultFailure(
          errorMessage: 'No consultation requests found',
          statusCode: 404
        );
      }
      final data = response as List<dynamic>;

      final consultationData = data.map((session) {
        return AppointmentModel(
          id: session['id'],
          serviceType: session['is_consultation'] ? 'Consultation' : 'Therapy Session',
          appointmentDate: DateTime.parse(session['timestamp']),
          timeSlot: session['timestamp'],
          isCompleted: DateTime.parse(session['timestamp']).isBefore(DateTime.now())
        );
      }).toList();

      return ActionResultSuccess(data: consultationData, statusCode: 200);
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500
      );
    }
  }

  @override
  Future<ActionResult> deleteAppointment(String id) async {
    try {
      await _supabaseClient.from('session').delete().eq('id', id);
      return ActionResultSuccess(
        data: 'Appointment deleted successfully',
        statusCode: 200
      );
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500
      );
    }
  }

  @override
  Future<ActionResult> getTodayActivities({DateTime? date}) async {
    try {
      final dateTime = date ?? DateTime.now();
      // Normalize date to UTC to ensure consistent date comparison
      final normalizedDate = dateTime.isUtc 
          ? dateTime 
          : DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
      final startDate = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 0, 0, 0);
      final endDate = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 23, 59, 59, 999);
      
      if (kDebugMode) {
        debugPrint('getTodayActivities: Fetching activities for date: $dateTime');
        debugPrint('getTodayActivities: Date range (UTC): ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
        debugPrint('getTodayActivities: Patient ID: ${_supabaseClient.auth.currentUser!.id}');
      }
      
      // Query using date range for TIMESTAMPTZ column, also fetch instructions from daily_activities
      final response = await _supabaseClient.from('daily_activity_logs')
      .select('*, activity:activity_id(id, instructions)')
      .eq('patient_id', _supabaseClient.auth.currentUser!.id)
      .gte('date', startDate.toIso8601String())
      .lte('date', endDate.toIso8601String())
      .maybeSingle();
      
      if (kDebugMode) {
        debugPrint('getTodayActivities: Query returned: ${response != null ? 'Found activity log' : 'No activity log found'}');
        if (response != null) {
          debugPrint('getTodayActivities: Activity log ID: ${response['id']}');
          debugPrint('getTodayActivities: Activity set ID: ${response['activity_id']}');
          debugPrint('getTodayActivities: Activity items count: ${(response['activity_items'] as List?)?.length ?? 0}');
          debugPrint('getTodayActivities: Date in log: ${response['date']}');
        } else {
          // Check if there are any logs at all for this patient
          final allLogs = await _supabaseClient.from('daily_activity_logs')
              .select('id, date, activity_id')
              .eq('patient_id', _supabaseClient.auth.currentUser!.id)
              .limit(5);
          debugPrint('getTodayActivities: Total logs for patient: ${allLogs.length}');
          if (allLogs.isNotEmpty) {
            debugPrint('getTodayActivities: Sample log dates: ${allLogs.map((l) => l['date']).toList()}');
          }
        }
      }
      
      if (response == null || response.isEmpty) {
        return ActionResultFailure(errorMessage: 'No activities found', statusCode: 404);
      }

    // Get instructions map from daily_activities if available
    final activityData = response['activity'] as Map<String, dynamic>?;
    final instructionsRaw = activityData?['instructions'];
    final parentNotes = response['parent_notes'] as List<dynamic>? ?? [];
    
    // Create a map of activity_id -> note from parent_notes
    final notesMap = <String, String>{};
    for (final noteData in parentNotes) {
      if (noteData is Map<String, dynamic>) {
        final activityId = noteData['activity_id'] as String?;
        final note = noteData['note'] as String?;
        if (activityId != null && note != null) {
          notesMap[activityId] = note;
        }
      }
    }
    
    // Extract instructions map - handle both Map and List formats
    final instructions = <String, String>{};
    if (instructionsRaw != null) {
      if (instructionsRaw is Map<String, dynamic>) {
        // Instructions stored as Map<String, String>
        instructionsRaw.forEach((key, value) {
          if (value is String) {
            instructions[key] = value;
          }
        });
      } else if (instructionsRaw is List) {
        // Instructions stored as List (legacy format or incorrect format)
        // Try to parse as List of Maps with activity_id and instructions
        for (final item in instructionsRaw) {
          if (item is Map<String, dynamic>) {
            final activityId = item['activity_id'] as String?;
            final instructionText = item['instructions'] as String?;
            if (activityId != null && instructionText != null) {
              instructions[activityId] = instructionText;
            }
          }
        }
      }
    }
    
    if (kDebugMode) {
      debugPrint('getTodayActivities: Instructions parsed - ${instructions.length} entries');
    }
    
    // Create PatientTaskModel list with notes and instructions
    // activity_items from JSONB is already parsed as List<Map<String, dynamic>>, not List<String>
    final rawActivityItems = response['activity_items'] as List? ?? [];
    
    if (kDebugMode) {
      debugPrint('getTodayActivities: Raw activity_items type: ${rawActivityItems.runtimeType}');
      debugPrint('getTodayActivities: Raw activity_items length: ${rawActivityItems.length}');
      if (rawActivityItems.isNotEmpty) {
        debugPrint('getTodayActivities: First item type: ${rawActivityItems.first.runtimeType}');
        debugPrint('getTodayActivities: First item: ${rawActivityItems.first}');
      }
    }
    
    final List<PatientTaskModel> activityItems = rawActivityItems.map((e) {
      // e is already a Map<String, dynamic> from JSONB, not a String
      final activity = e is Map<String, dynamic> ? e : (e is String ? jsonDecode(e) : e as Map<String, dynamic>);
      final activityId = activity['id'] as String? ?? '';
      final activityName = activity['activity'] as String?;
      final isCompleted = activity['is_completed'] as bool? ?? false;
      
      if (kDebugMode) {
        debugPrint('getTodayActivities: Processing activity item - id: $activityId, name: $activityName, completed: $isCompleted');
      }
      
      return PatientTaskModel(
        activityId: activityId,
        activityName: activityName,
        isCompleted: isCompleted,
        note: notesMap[activityId],
        instructions: instructions[activityId],
      );
    }).toList();
    
    if (kDebugMode) {
      debugPrint('getTodayActivities: Created ${activityItems.length} PatientTaskModel items');
      if (activityItems.isEmpty && rawActivityItems.isNotEmpty) {
        debugPrint('getTodayActivities: ERROR - Failed to parse activity_items!');
      }
    }
    
    if (kDebugMode) {
      debugPrint('getTodayActivities: Returning ${activityItems.length} tasks');
      if (activityItems.isNotEmpty) {
        debugPrint('getTodayActivities: First task - id: ${activityItems.first.activityId}, name: ${activityItems.first.activityName}');
      }
    }
    
    return ActionResultSuccess(data: (activityItems, response['id'], response['activity_id'], instructions), statusCode: 200);
    } catch(e, stackTrace) {
      if (kDebugMode) {
        debugPrint('getTodayActivities: ERROR - $e');
        debugPrint('getTodayActivities: Stack trace: $stackTrace');
      }
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> updateActivityCompletion({
    required List<PatientTaskModel> tasks,
    String? activityId,
    String? activitySetId,
    DateTime? date,
  }) async {
    try {
      // Build the query
      var query = _supabaseClient.from('daily_activity_logs')
        .update({
          'activity_items': tasks.map((e) => jsonEncode(e.toMap())).toList()
        })
        .eq('id', activityId ?? '')
        .eq('activity_id', activitySetId ?? '')
        .eq('patient_id', _supabaseClient.auth.currentUser!.id);
      
      // If date is provided, filter by date range to ensure we update the correct record
      if (date != null) {
        final normalizedDate = date.isUtc 
            ? date 
            : DateTime.utc(date.year, date.month, date.day);
        final startDate = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 0, 0, 0);
        final endDate = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 23, 59, 59, 999);
        
        query = query
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
      }
      
      await query;

      return ActionResultSuccess(data: 'Activity updated successfully', statusCode: 200);
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> saveActivityNote({
    required String activityId,
    required String activitySetId,
    required String note,
    required DateTime date,
  }) async {
    try {
      // Normalize date to UTC
      final normalizedDate = date.isUtc 
          ? date 
          : DateTime.utc(date.year, date.month, date.day);
      final startDate = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 0, 0, 0);
      final endDate = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day, 23, 59, 59, 999);
      
      // Get existing log entry
      final response = await _supabaseClient
          .from('daily_activity_logs')
          .select('id, parent_notes, activity_items')
          .eq('activity_id', activitySetId)
          .eq('patient_id', _supabaseClient.auth.currentUser!.id)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .maybeSingle();
      
      if (response == null) {
        return ActionResultFailure(
          errorMessage: 'Activity log not found for this date',
          statusCode: 404,
        );
      }
      
      // Get existing parent_notes or initialize empty list
      List<dynamic> parentNotes = [];
      if (response['parent_notes'] != null) {
        parentNotes = List<dynamic>.from(response['parent_notes']);
      }
      
      // Remove existing note for this activity if any
      parentNotes.removeWhere((n) => n['activity_id'] == activityId);
      
      // Add new note
      parentNotes.add({
        'activity_id': activityId,
        'note': note,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      
      // Update the log entry
      await _supabaseClient
          .from('daily_activity_logs')
          .update({
            'parent_notes': parentNotes,
          })
          .eq('id', response['id']);
      
      return ActionResultSuccess(data: 'Note saved successfully', statusCode: 200);
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> getReports({required DateTime date}) async {
    try {
      final startDate = DateTime(date.year, date.month, 1, 0, 0, 0);
      final endDate = DateTime(date.year, date.month + 1, 1, 0, 0, 0);
      final response = await _supabaseClient.from(
        'daily_activities',
      ).select('activity_name, daily_activity_logs(*)')
      .eq('patient_id', _supabaseClient.auth.currentUser!.id)
      .eq('is_active', 'true')
      .gte('daily_activity_logs.date', startDate.toIso8601String())
      .lte('daily_activity_logs.date', endDate.toIso8601String());

      if(response.isEmpty) {
        return ActionResultFailure(errorMessage: 'No activities found', statusCode: 404);
      }

      List<String> completedActivities = [];
      List<String> incompleteActivities = [];

      for(var i = 0; i < response.length; i++) {
        final dailyActivityLogs = response[i]['daily_activity_logs'];
        for(var j = 0; j < dailyActivityLogs.length; j++) {
          final activityItems = dailyActivityLogs[j]['activity_items'];
          bool isCompleted = true;
          for(var k = 0; k < activityItems.length; k++) {
            final activityItem = activityItems[k] is String ? jsonDecode(activityItems[k]) : activityItems[k];
            if(activityItem['is_completed'] == false) { 
              isCompleted = false;
              break;
            }
          }
          if(isCompleted) {
            completedActivities.add(response[i]['activity_name']);
          } else {
            incompleteActivities.add(response[i]['activity_name']);
          }
        }
      }

      final regresstionResponse = await _supabaseClient.from(
        'therapy_goal'
      ).select('regressions')
      .eq('patient_id', _supabaseClient.auth.currentUser!.id)
      .gte('performed_on', startDate.toIso8601String())
      .lte('performed_on', endDate.toIso8601String());

      List<String> regressions = [];
      for(var i = 0; i < regresstionResponse.length; i++) {
        final regression = regresstionResponse[i]['regressions'];
        for(var j = 0; j < regression.length; j++) {
          final regressionItem = regression[j] is String ? jsonDecode(regression[j]) : regression[j];

          regressions.add(regressionItem['name']);
        }
      }
      
      return ActionResultSuccess(data: (completedActivities, incompleteActivities, regressions), statusCode: 200);
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  // Package-related methods
  Future<ActionResult> fetchClinicPackages() async {
    try {
      // First get patient's clinic_id
      final patientResponse = await _supabaseClient
          .from('patient')
          .select('clinic_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (patientResponse == null || patientResponse['clinic_id'] == null) {
        return ActionResultFailure(
          errorMessage: 'Patient not assigned to a clinic',
          statusCode: 404,
        );
      }

      final clinicId = patientResponse['clinic_id'];

      // Fetch packages for the clinic with therapy details
      final packagesResponse = await _supabaseClient
          .from('package')
          .select('''
            *,
            package_therapy_details(
              *,
              therapy:therapy_type_id(name)
            )
          ''')
          .eq('clinic_id', clinicId)
          .eq('is_active', true);

      if (packagesResponse.isEmpty) {
        return ActionResultFailure(
          errorMessage: 'No packages available for your clinic',
          statusCode: 404,
        );
      }

      final packages = packagesResponse.map((pkg) {
        final therapyDetails = (pkg['package_therapy_details'] as List?)?.map((td) {
          return {
            'id': td['id'],
            'therapy_type_id': td['therapy_type_id'],
            'therapy_name': td['therapy']?['name'],
            'session_count': td['session_count'],
            'frequency_per_week': td['frequency_per_week'],
            'session_duration_minutes': td['session_duration_minutes'],
          };
        }).toList();

        return {
          'id': pkg['id'],
          'name': pkg['name'],
          'description': pkg['description'],
          'price': pkg['price'],
          'validity_days': pkg['validity_days'],
          'is_active': pkg['is_active'],
          'clinic_id': pkg['clinic_id'],
          'therapy_details': therapyDetails,
        };
      }).toList();

      return ActionResultSuccess(data: packages, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  Future<ActionResult> assignPackageToPatient({
    required String packageId,
    required DateTime startsAt,
  }) async {
    try {
      // Get patient's clinic_id
      final patientResponse = await _supabaseClient
          .from('patient')
          .select('clinic_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (patientResponse == null || patientResponse['clinic_id'] == null) {
        return ActionResultFailure(
          errorMessage: 'Patient not assigned to a clinic',
          statusCode: 404,
        );
      }

      final clinicId = patientResponse['clinic_id'];

      // Get package validity
      final packageResponse = await _supabaseClient
          .from('package')
          .select('validity_days')
          .eq('id', packageId)
          .maybeSingle();

      final validityDays = packageResponse?['validity_days'] as int? ?? 90;
      final expiresAt = startsAt.add(Duration(days: validityDays));

      // Create patient_package record
      await _supabaseClient.from('patient_package').insert({
        'patient_id': _supabaseClient.auth.currentUser!.id,
        'package_id': packageId,
        'clinic_id': clinicId,
        'assigned_by': _supabaseClient.auth.currentUser!.id, // Patient self-selected
        'starts_at': startsAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'status': 'active',
        'sessions_used': {},
      });

      return ActionResultSuccess(
        data: 'Package assigned successfully',
        statusCode: 200,
      );
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  Future<ActionResult> getPatientActivePackage() async {
    try {
      final response = await _supabaseClient
          .from('patient_package')
          .select('''
            *,
            package:package_id(*)
          ''')
          .eq('patient_id', _supabaseClient.auth.currentUser!.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        return ActionResultFailure(
          errorMessage: 'No active package found',
          statusCode: 404,
        );
      }

      return ActionResultSuccess(data: response, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> getProgressMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? therapyTypeId,
  }) async {
    try {
      final patientId = _supabaseClient.auth.currentUser!.id;
      
      // Default to last 30 days if not specified
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));
      
      // Normalize dates to UTC
      final startOfRange = DateTime.utc(start.year, start.month, start.day, 0, 0, 0);
      final endOfRange = DateTime.utc(end.year, end.month, end.day, 23, 59, 59, 999);
      
      // 1. Fetch patient's active package and assigned therapy types
      final activePackage = await _supabaseClient
          .from('patient_package')
          .select('package_id, id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (activePackage == null) {
        return ActionResultFailure(
          errorMessage: 'No active package found',
          statusCode: 404,
        );
      }

      final packageId = activePackage['package_id'] as String;
      
      // Get assigned therapy types
      final assignedTypesResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id')
          .eq('patient_id', patientId)
          .eq('is_active', true);

      if (assignedTypesResponse.isEmpty) {
        return ActionResultFailure(
          errorMessage: 'No therapists assigned',
          statusCode: 404,
        );
      }

      final assignedTherapyTypeIds = assignedTypesResponse
          .map((a) => a['therapy_type_id'] as String)
          .toSet()
          .toList();

      final filterTherapyTypeIds = therapyTypeId != null && assignedTherapyTypeIds.contains(therapyTypeId)
          ? [therapyTypeId]
          : assignedTherapyTypeIds;

      // 2. Fetch therapy goals for the date range
      final goalsResponse = await _supabaseClient
          .from('therapy_goal')
          .select('goals, observations, regressions, goal_achievement_status, performed_on, therapy_type_id')
          .eq('patient_id', patientId)
          .filter('therapy_type_id', 'in', filterTherapyTypeIds)
          .gte('performed_on', startOfRange.toIso8601String())
          .lte('performed_on', endOfRange.toIso8601String());

      // 3. Calculate metrics
      int totalGoals = 0;
      int achievedGoals = 0;
      int totalObservations = 0;
      int totalRegressions = 0;
      int sessionsWithGoals = 0;

      for (final goal in goalsResponse) {
        final goalsList = goal['goals'] as List<dynamic>? ?? [];
        final observationsList = goal['observations'] as List<dynamic>? ?? [];
        final regressionsList = goal['regressions'] as List<dynamic>? ?? [];
        final achievementStatus = goal['goal_achievement_status'] as Map<String, dynamic>?;

        totalGoals += goalsList.length;
        totalObservations += observationsList.length;
        totalRegressions += regressionsList.length;

        if (goalsList.isNotEmpty) {
          sessionsWithGoals++;
        }

        // Count achieved goals
        if (achievementStatus != null) {
          for (final status in achievementStatus.values) {
            if (status == 'achieved') {
              achievedGoals++;
            }
          }
        }
      }

      // 4. Calculate attendance rate (sessions with goals / total days in range)
      final daysInRange = endOfRange.difference(startOfRange).inDays + 1;
      final attendanceRate = daysInRange > 0 ? (sessionsWithGoals / daysInRange) * 100 : 0.0;

      // 5. Return metrics
      final metrics = {
        'goalsAchieved': achievedGoals,
        'totalGoals': totalGoals,
        'goalsAchievementRate': totalGoals > 0 ? (achievedGoals / totalGoals) * 100 : 0.0,
        'observationsCount': totalObservations,
        'regressionsCount': totalRegressions,
        'sessionsCount': sessionsWithGoals,
        'attendanceRate': attendanceRate,
        'startDate': startOfRange.toIso8601String(),
        'endDate': endOfRange.toIso8601String(),
      };

      return ActionResultSuccess(data: metrics, statusCode: 200);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getProgressMetrics: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> getHistoricalTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? therapyTypeId,
  }) async {
    try {
      final patientId = _supabaseClient.auth.currentUser!.id;
      
      // Normalize dates to UTC
      final startOfRange = DateTime.utc(startDate.year, startDate.month, startDate.day, 0, 0, 0);
      final endOfRange = DateTime.utc(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
      
      // 1. Fetch patient's active package and assigned therapy types
      final activePackage = await _supabaseClient
          .from('patient_package')
          .select('package_id, id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (activePackage == null) {
        return ActionResultFailure(
          errorMessage: 'No active package found',
          statusCode: 404,
        );
      }

      final packageId = activePackage['package_id'] as String;
      
      // Get assigned therapy types
      final assignedTypesResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id')
          .eq('patient_id', patientId)
          .eq('is_active', true);

      if (assignedTypesResponse.isEmpty) {
        return ActionResultFailure(
          errorMessage: 'No therapists assigned',
          statusCode: 404,
        );
      }

      final assignedTherapyTypeIds = assignedTypesResponse
          .map((a) => a['therapy_type_id'] as String)
          .toSet()
          .toList();

      final filterTherapyTypeIds = therapyTypeId != null && assignedTherapyTypeIds.contains(therapyTypeId)
          ? [therapyTypeId]
          : assignedTherapyTypeIds;

      // 2. Fetch therapy goals for the date range
      final goalsResponse = await _supabaseClient
          .from('therapy_goal')
          .select('goals, observations, regressions, performed_on, therapy_type_id, therapy:therapy_type_id(name)')
          .eq('patient_id', patientId)
          .filter('therapy_type_id', 'in', filterTherapyTypeIds)
          .gte('performed_on', startOfRange.toIso8601String())
          .lte('performed_on', endOfRange.toIso8601String())
          .order('performed_on', ascending: true);

      // 3. Group by date and calculate daily metrics
      final Map<String, Map<String, dynamic>> trendsByDate = {};
      
      for (final goal in goalsResponse) {
        final performedOn = DateTime.parse(goal['performed_on'] as String);
        final dateKey = '${performedOn.year}-${performedOn.month.toString().padLeft(2, '0')}-${performedOn.day.toString().padLeft(2, '0')}';
        
        final goalsList = goal['goals'] as List<dynamic>? ?? [];
        final observationsList = goal['observations'] as List<dynamic>? ?? [];
        final regressionsList = goal['regressions'] as List<dynamic>? ?? [];
        final therapy = goal['therapy'] as Map<String, dynamic>?;
        final therapyTypeName = therapy?['name'] as String? ?? 'Unknown';

        if (!trendsByDate.containsKey(dateKey)) {
          trendsByDate[dateKey] = {
            'date': dateKey,
            'goalsCount': 0,
            'observationsCount': 0,
            'regressionsCount': 0,
            'therapyTypes': <String>[],
          };
        }

        final dayData = trendsByDate[dateKey]!;
        dayData['goalsCount'] = (dayData['goalsCount'] as int) + goalsList.length;
        dayData['observationsCount'] = (dayData['observationsCount'] as int) + observationsList.length;
        dayData['regressionsCount'] = (dayData['regressionsCount'] as int) + regressionsList.length;
        
        final therapyTypes = dayData['therapyTypes'] as List<String>;
        if (!therapyTypes.contains(therapyTypeName)) {
          therapyTypes.add(therapyTypeName);
        }
      }

      // 4. Convert to list sorted by date
      final trendsList = trendsByDate.values.toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

      return ActionResultSuccess(data: trendsList, statusCode: 200);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getHistoricalTrends: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> analyzeMilestones() async {
    try {
      final patientId = _supabaseClient.auth.currentUser!.id;
      
      // Get the therapist ID from patient_therapist_assignment
      final assignmentResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapist_id')
          .eq('patient_id', patientId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (assignmentResponse == null) {
        return ActionResultFailure(
          errorMessage: 'No active therapist assignment found',
          statusCode: 404,
        );
      }

      final therapistId = assignmentResponse['therapist_id'] as String;

      final response = await _supabaseClient.functions.invoke(
        'analyze-milestones',
        body: {
          'patientId': patientId,
          'therapistId': therapistId,
        },
      );

      if (response.status != 200) {
        return ActionResultFailure(
          errorMessage: 'Failed to analyze milestones',
          statusCode: response.status,
        );
      }

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return ActionResultSuccess(
          data: data['data'],
          statusCode: 200,
        );
      } else {
        return ActionResultFailure(
          errorMessage: data['error'] ?? 'Unknown error',
          statusCode: 500,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('analyzeMilestones: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }
}
