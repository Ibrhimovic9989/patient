import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapist/core/entities/therapy_entities/therapy_entities.dart';
import 'package:therapist/core/entities/therapy_entities/therapy_type_entity.dart';
import 'package:therapist/core/result/result.dart';
import 'package:therapist/model/therapy_models/therapy_models.dart';
import 'package:uuid/uuid.dart';

import '../core/entities/daily_activity_entities/daily_activity_model.dart' show DailyActivityModel;
import '../core/entities/daily_activity_entities/daily_activity_response.dart' show DailyActivityResponse, DailyActivityResponseMapper;
import '../core/repository/repository.dart';
import '../model/daily_activities/daily_activity_response_model.dart';

class SupabaseTherapyRepository implements TherapyRepository {
  final _supabaseClient = Supabase.instance.client;

  @override
  Future<ActionResult> getTherapyTypes() async {
    try {
      final response = await _supabaseClient.from('therapy').select('*');
      final data = response
          .map((e) => TherapyTypeEntityMapper.fromMap(e).toModel())
          .toList();
      return ActionResultSuccess(data: data, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> getTherapyTypesForPatient(String patientId) async {
    try {
      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Starting for patientId: $patientId');
      }
      
      // First, let's check all packages for this patient to see what exists
      final allPackagesResponse = await _supabaseClient
          .from('patient_package')
          .select('*')
          .eq('patient_id', patientId);
      
      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: All packages for patient: ${allPackagesResponse.length}');
        if (allPackagesResponse.isNotEmpty) {
          debugPrint('getTherapyTypesForPatient: First package data: ${allPackagesResponse.first}');
          debugPrint('getTherapyTypesForPatient: Package status values: ${allPackagesResponse.map((p) => p['status']).toList()}');
        }
      }
      
      // 1. Fetch patient's active package
      final packageResponse = await _supabaseClient
          .from('patient_package')
          .select('package_id, id, status, patient_id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();

      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Package response (filtered by active): $packageResponse');
      }
      
      // If no active package found, try without status filter to see what exists
      if (packageResponse == null) {
        final anyPackageResponse = await _supabaseClient
            .from('patient_package')
            .select('package_id, id, status, patient_id')
            .eq('patient_id', patientId)
            .maybeSingle();
        if (kDebugMode) {
          debugPrint('getTherapyTypesForPatient: Any package (no status filter): $anyPackageResponse');
        }
      }

      if (packageResponse == null) {
        if (kDebugMode) {
          debugPrint('getTherapyTypesForPatient: No active package found for patient');
        }
        return ActionResultFailure(
          errorMessage: 'Patient does not have an active package',
          statusCode: 404,
        );
      }

      final packageId = packageResponse['package_id'] as String;
      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Found package ID: $packageId');
      }

      // 2. Get therapy types from package_therapy_details
      // First, let's check if there are any records at all for this package
      final allTherapyDetails = await _supabaseClient
          .from('package_therapy_details')
          .select('*')
          .eq('package_id', packageId);
      
      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: All therapy details (no join) count: ${allTherapyDetails.length}');
        if (allTherapyDetails.isNotEmpty) {
          debugPrint('getTherapyTypesForPatient: First therapy detail: ${allTherapyDetails.first}');
        }
      }
      
      // Now try with the join
      final therapyDetailsResponse = await _supabaseClient
          .from('package_therapy_details')
          .select('therapy_type_id, therapy:therapy_type_id(*)')
          .eq('package_id', packageId);

      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Therapy details response count (with join): ${therapyDetailsResponse.length}');
        debugPrint('getTherapyTypesForPatient: Therapy details: $therapyDetailsResponse');
      }

      if (therapyDetailsResponse.isEmpty) {
        if (kDebugMode) {
          debugPrint('getTherapyTypesForPatient: No therapy types found in package');
        }
        return ActionResultSuccess(data: <TherapyTypeModel>[], statusCode: 200);
      }

      // 3. Extract unique therapy types
      final therapyTypes = <String, Map<String, dynamic>>{};
      for (final detail in therapyDetailsResponse) {
        final therapy = detail['therapy'] as Map<String, dynamic>?;
        if (kDebugMode) {
          debugPrint('getTherapyTypesForPatient: Processing detail - therapy: $therapy');
        }
        if (therapy != null) {
          final therapyId = therapy['id'] as String;
          if (!therapyTypes.containsKey(therapyId)) {
            therapyTypes[therapyId] = therapy;
          }
        }
      }

      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Extracted ${therapyTypes.length} unique therapy types');
      }

      // 4. Convert to models
      final data = therapyTypes.values
          .map((e) {
            try {
              return TherapyTypeEntityMapper.fromMap(e).toModel();
            } catch (ex) {
              if (kDebugMode) {
                debugPrint('getTherapyTypesForPatient: Error mapping therapy type: $ex, data: $e');
              }
              rethrow;
            }
          })
          .toList();

      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Successfully converted to ${data.length} models');
      }
      return ActionResultSuccess(data: data, statusCode: 200);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('getTherapyTypesForPatient: Exception occurred: $e');
        debugPrint('getTherapyTypesForPatient: Stack trace: $stackTrace');
      }
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> addTherapyActivities(
      String therapyTypeId, String activity) async {
    try {
      final response = await _supabaseClient
          .from('activity_master')
          .select()
          .eq('activity_text', activity)
          .maybeSingle();

      if (response != null) {
        List<String> existingTherapies =
            List<String>.from(response['applicable_therapies']);

        if (!existingTherapies.contains(therapyTypeId)) {
          existingTherapies.add(therapyTypeId);

          await _supabaseClient.from('activity_master').update({
            'applicable_therapies': existingTherapies,
          }).eq('id', response['id']);
        }
      } else {
        await _supabaseClient.from('activity_master').insert({
          'activity_text': activity,
          'applicable_therapies': [therapyTypeId],
        });
      }

      return ActionResultSuccess(
          data: 'Activity Added Successfully', statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> addTherapyGoals(
      String therapyTypeId, String goal) async {
    try {
      final response = await _supabaseClient
          .from('goal_master')
          .select()
          .eq('goal_text', goal)
          .maybeSingle();

      if (response != null) {
        List<String> existingTherapies =
            List<String>.from(response['applicable_therapies']);

        if (!existingTherapies.contains(therapyTypeId)) {
          existingTherapies.add(therapyTypeId);

          await _supabaseClient.from('goal_master').update({
            'applicable_therapies': existingTherapies,
          }).eq('id', response['id']);
        }
      } else {
        await _supabaseClient.from('goal_master').insert({
          'goal_text': goal,
          'applicable_therapies': [therapyTypeId],
        });
      }

      return ActionResultSuccess(
          data: 'Goal Added Successfully', statusCode: 200);
    } catch (error) {
      return ActionResultFailure(
          errorMessage: error.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> addTherapyObservations(
      String therapyTypeId, String observation) async {
    try {
      final response = await _supabaseClient
          .from('observation_master')
          .select()
          .eq('observation_text', observation)
          .maybeSingle();

      if (response != null) {
        List<String> existingTherapies =
            List<String>.from(response['applicable_therapies']);

        if (!existingTherapies.contains(therapyTypeId)) {
          existingTherapies.add(therapyTypeId);

          await _supabaseClient.from('observation_master').update({
            'applicable_therapies': existingTherapies,
          }).eq('id', response['id']);
        }
      } else {
        await _supabaseClient.from('observation_master').insert({
          'observation_text': observation,
          'applicable_therapies': [therapyTypeId],
        });
      }

      return ActionResultSuccess(
          data: 'Observation Added Successfully', statusCode: 200);
    } catch (error) {
      return ActionResultFailure(
          errorMessage: error.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> addTherapyRegressions(
      String therapyTypeId, String regression) async {
    try {
      final response = await _supabaseClient
          .from('regression_master')
          .select()
          .eq('regression_text', regression)
          .maybeSingle();

      if (response != null) {
        List<String> existingTherapies =
            List<String>.from(response['applicable_therapies']);

        if (!existingTherapies.contains(therapyTypeId)) {
          existingTherapies.add(therapyTypeId);

          await _supabaseClient.from('regression_master').update({
            'applicable_therapies': existingTherapies,
          }).eq('id', response['id']);
        }
      } else {
        await _supabaseClient.from('regression_master').insert({
          'regression_text': regression,
          'applicable_therapies': [therapyTypeId],
        });
      }

      return ActionResultSuccess(
          data: 'Regression Added Successfully', statusCode: 200);
    } catch (error) {
      return ActionResultFailure(
          errorMessage: error.toString(), statusCode: 500);
    }
  }
  
  @override
  Future<ActionResult> getAllActivities(String therapyTypeId) async {
    try {
      final response = await _supabaseClient
          .from('activity_master')
          .select('id, activity_text',)
          .contains('applicable_therapies', [therapyTypeId]);
      
      if(response.isNotEmpty) {
        final data = response.map((e) => TherapyEntity(id: e['id'], name: e['activity_text']) ).toList();
        return ActionResultSuccess(data: data.map((e) => e.toModel()).toList(), statusCode: 200);
      } else {
        return ActionResultSuccess(data: <TherapyModel>[], statusCode: 200);
      }
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }
  
  @override
  Future<ActionResult> getAllGoals(String therapyTypeId) async {
    try {
      final response = await _supabaseClient
          .from('goal_master')
          .select('id, goal_text',)
          .contains('applicable_therapies', [therapyTypeId]);
      
      if(response.isNotEmpty) {
        final data = response.map((e) => TherapyEntity(id: e['id'], name: e['goal_text']) ).toList();
        return ActionResultSuccess(data: data.map((e) => e.toModel()).toList(), statusCode: 200);
      } else {
        return ActionResultSuccess(data: <TherapyModel>[], statusCode: 200);
      }
    } catch (e)  {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }
  
  @override
  Future<ActionResult> getAllObservations(String therapyTypeId) async {
    try {
      final response = await _supabaseClient
          .from('observation_master')
          .select('id, observation_text',)
          .contains('applicable_therapies', [therapyTypeId]);
      
      if(response.isNotEmpty) {
        final data = response.map((e) => TherapyEntity(id: e['id'], name: e['observation_text']) ).toList();
        return ActionResultSuccess(data: data.map((e) => e.toModel()).toList(), statusCode: 200);
      } else {
        return ActionResultSuccess(data: <TherapyModel>[], statusCode: 200);
      }
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }
  
  @override
  Future<ActionResult> getAllRegressions(String therapyTypeId) async {
    try {
      final response = await _supabaseClient
          .from('regression_master')
          .select('id, regression_text',)
          .contains('applicable_therapies', [therapyTypeId]);
      
      if(response.isNotEmpty) {
        final data = response.map((e) => TherapyEntity(id: e['id'], name: e['regression_text']) ).toList();
        return ActionResultSuccess(data: data.map((e) => e.toModel()).toList(), statusCode: 200);
      } else {
        return ActionResultSuccess(data: <TherapyModel>[], statusCode: 200);
      }
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }
  
  @override
  Future<ActionResult> saveTherapyGoals(TherapyGoalEntity therapyGoalEntity) async {
    try {
      if (therapyGoalEntity.patientId == null) {
        return ActionResultFailure(
          errorMessage: 'Patient ID is required',
          statusCode: 400,
        );
      }

      // 1. Fetch patient's active package
      final packageResponse = await _supabaseClient
          .from('patient_package')
          .select('package_id, id')
          .eq('patient_id', therapyGoalEntity.patientId!)
          .eq('status', 'active')
          .maybeSingle();
      
      if (packageResponse == null) {
        return ActionResultFailure(
          errorMessage: 'Patient does not have an active package',
          statusCode: 400,
        );
      }
      
      final packageId = packageResponse['package_id'] as String;
      final patientPackageId = packageResponse['id'] as String;
      
      // 2. Validate therapy type is in package
      final therapyDetails = await _supabaseClient
          .from('package_therapy_details')
          .select('therapy_type_id')
          .eq('package_id', packageId)
          .eq('therapy_type_id', therapyGoalEntity.therapyTypeId)
          .maybeSingle();
      
      if (therapyDetails == null) {
        return ActionResultFailure(
          errorMessage: 'Therapy type is not part of patient\'s package',
          statusCode: 400,
        );
      }
      
      // 3. Validate therapist is assigned to this patient for this therapy type
      final assignment = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('id')
          .eq('patient_id', therapyGoalEntity.patientId!)
          .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
          .eq('therapy_type_id', therapyGoalEntity.therapyTypeId)
          .eq('is_active', true)
          .maybeSingle();
      
      if (assignment == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist is not assigned to this patient for this therapy type',
          statusCode: 403,
        );
      }
      
      // 4. Check if therapy goal already exists for this patient, date, and therapy type
      // Normalize to UTC to ensure consistent date comparison
      final startOfDay = DateTime.utc(
        therapyGoalEntity.performedOn.year,
        therapyGoalEntity.performedOn.month,
        therapyGoalEntity.performedOn.day,
        0, 0, 0,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final existingGoal = await _supabaseClient
          .from('therapy_goal')
          .select('id')
          .eq('patient_id', therapyGoalEntity.patientId!)
          .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
          .eq('therapy_type_id', therapyGoalEntity.therapyTypeId)
          .gte('performed_on', startOfDay.toIso8601String())
          .lt('performed_on', endOfDay.toIso8601String())
          .maybeSingle();
      
      // 5. Prepare the data map
      final updatedEntity = therapyGoalEntity.copyWith(
        packageId: packageId,
        patientPackageId: patientPackageId,
        therapistId: _supabaseClient.auth.currentUser!.id,
      );
      
      final dataMap = updatedEntity.toMap();
      
      // Convert TherapyModel lists to JSONB format (list of objects with id and name)
      dataMap['goals'] = updatedEntity.goals.map((g) => {'id': g.id, 'name': g.name}).toList();
      dataMap['observations'] = updatedEntity.observations.map((o) => {'id': o.id, 'name': o.name}).toList();
      dataMap['regressions'] = updatedEntity.regressions.map((r) => {'id': r.id, 'name': r.name}).toList();
      dataMap['activities'] = updatedEntity.activities.map((a) => {'id': a.id, 'name': a.name}).toList();
      
      if (kDebugMode) {
        debugPrint('saveTherapyGoals: Saving therapy goal data: $dataMap');
        debugPrint('saveTherapyGoals: Therapy Type ID being saved: ${therapyGoalEntity.therapyTypeId}');
        debugPrint('saveTherapyGoals: Performed On date being saved: ${therapyGoalEntity.performedOn}');
        debugPrint('saveTherapyGoals: Performed On ISO string: ${therapyGoalEntity.performedOn.toIso8601String()}');
      }
      
      // 6. Insert or update
      if (existingGoal != null) {
        // Update existing record
        await _supabaseClient
            .from('therapy_goal')
            .update(dataMap)
            .eq('id', existingGoal['id']);
        if (kDebugMode) {
          debugPrint('saveTherapyGoals: Updated existing therapy goal');
        }
        return ActionResultSuccess(data: 'Therapy Goal Updated Successfully', statusCode: 200);
      } else {
        // Insert new record
        await _supabaseClient
            .from('therapy_goal')
            .insert(dataMap);
        if (kDebugMode) {
          debugPrint('saveTherapyGoals: Created new therapy goal');
        }
        return ActionResultSuccess(data: 'Therapy Goal Saved Successfully', statusCode: 200);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('saveTherapyGoals: Error occurred: $e');
        debugPrint('saveTherapyGoals: Stack trace: $stackTrace');
      }
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> getAllDailyActivities(String patientId) async {
    try {
      final response = await _supabaseClient.from('daily_activities')
      .select('*')
      .eq('patient_id', patientId)
      .eq('therapist_id', _supabaseClient.auth.currentUser!.id);

      if(response.isNotEmpty) {
        final data = response.map((e) => DailyActivityResponseMapper.fromMap(e).toModel()).toList();
        return ActionResultSuccess(data: data, statusCode: 200);
      } else {
        return ActionResultSuccess(data: <DailyActivityResponse>[], statusCode: 200);
      }
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> addOrUpdateDailyActivity(DailyActivityResponse dailyActivity) async {
    try {
      final updatedDailyActivity = dailyActivity.copyWith(
        therapistId: _supabaseClient.auth.currentUser!.id,
        id: dailyActivity.id.isEmpty ? const Uuid().v4() : dailyActivity.id,
      );
      if(dailyActivity.id.isNotEmpty) {
        await _supabaseClient.from('daily_activities').update(
          updatedDailyActivity.toMap()
        ).eq('id', dailyActivity.id);
        // Delete old activity logs when updating
        await _supabaseClient.from('daily_activity_logs')
            .delete()
            .eq('activity_id', dailyActivity.id);
      } else {
        await _supabaseClient.from('daily_activities').insert(
          updatedDailyActivity.toMap()
        );
      }
      _addDailyActivityLog(updatedDailyActivity);
      return ActionResultSuccess(data: 'Daily Activity Added Successfully', statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  Future<void> _addDailyActivityLog(DailyActivityResponse dailyActivity) async {
    // Parse dates and normalize to UTC
    final startDateParsed = DateTime.parse(dailyActivity.startTime);
    final endDateParsed = DateTime.parse(dailyActivity.endTime);
    
    // Normalize to UTC dates (just the date part, no time)
    final startDate = DateTime.utc(startDateParsed.year, startDateParsed.month, startDateParsed.day);
    final endDate = DateTime.utc(endDateParsed.year, endDateParsed.month, endDateParsed.day);

    // Convert activityList to JSON format for activity_items
    final activityItemsJson = dailyActivity.activityList.map((activity) => {
      'id': activity.id,
      'activity': activity.activity,
      'is_completed': activity.isCompleted,
    }).toList();

    if (kDebugMode) {
      debugPrint('_addDailyActivityLog: Activity set: ${dailyActivity.id}');
      debugPrint('_addDailyActivityLog: Date range: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');
      debugPrint('_addDailyActivityLog: Days of week: ${dailyActivity.daysOfWeek}');
      debugPrint('_addDailyActivityLog: Activity items count: ${activityItemsJson.length}');
    }

    for (DateTime date = startDate;
       !date.isAfter(endDate);
       date = date.add(const Duration(days: 1))) {
    
    // Convert DateTime.weekday (1-7, Mon=1, Sun=7) to 0-6 format (Sun=0, Sat=6)
    final dayOfWeek = date.weekday == 7 ? 0 : date.weekday; 
    if (!dailyActivity.daysOfWeek.contains(dayOfWeek.toString())) {
      if (kDebugMode) {
        debugPrint('_addDailyActivityLog: Skipping ${date.toIso8601String()} (day of week: $dayOfWeek not in ${dailyActivity.daysOfWeek})');
      }
      continue;
    }
    
    // Normalize date to UTC midnight to ensure consistent date storage
    final normalizedDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
      0, // hour
      0, // minute
      0, // second
    );
    
    if (kDebugMode) {
      debugPrint('_addDailyActivityLog: Creating log for date: ${normalizedDate.toIso8601String()}, activity_id: ${dailyActivity.id}');
    }
    
    try {
      await _supabaseClient.from('daily_activity_logs').insert({
        'activity_id': dailyActivity.id,
        'date': normalizedDate.toIso8601String(),
        'activity_items': activityItemsJson,
        'patient_id': dailyActivity.patientId,
      });
      if (kDebugMode) {
        debugPrint('_addDailyActivityLog: Successfully created log for ${normalizedDate.toIso8601String()}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('_addDailyActivityLog: Error creating log for ${normalizedDate.toIso8601String()}: $e');
      }
      rethrow;
    }
  }
  }

  @override
  Future<ActionResult> deleteDailyActivity(String activitySetId) async {
    try {
      await _supabaseClient.from('daily_activities').delete().eq('id', activitySetId);
      return ActionResultSuccess(data: 'Daily Activity Deleted Successfully', statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<ActionResult> getPatientProgressMetrics(
    String patientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final therapistId = _supabaseClient.auth.currentUser!.id;
      
      // Default to last 30 days if not specified
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));
      
      // Normalize dates to UTC
      final startOfRange = DateTime.utc(start.year, start.month, start.day, 0, 0, 0);
      final endOfRange = DateTime.utc(end.year, end.month, end.day, 23, 59, 59, 999);
      
      // Verify therapist is assigned to this patient
      final assignment = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id')
          .eq('patient_id', patientId)
          .eq('therapist_id', therapistId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (assignment == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist is not assigned to this patient',
          statusCode: 403,
        );
      }

      // Fetch therapy goals for the date range
      final goalsResponse = await _supabaseClient
          .from('therapy_goal')
          .select('goals, observations, regressions, goal_achievement_status, performed_on, therapy_type_id')
          .eq('patient_id', patientId)
          .eq('therapist_id', therapistId)
          .gte('performed_on', startOfRange.toIso8601String())
          .lte('performed_on', endOfRange.toIso8601String());

      // Calculate metrics
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

      // Calculate attendance rate
      final daysInRange = endOfRange.difference(startOfRange).inDays + 1;
      final attendanceRate = daysInRange > 0 ? (sessionsWithGoals / daysInRange) * 100 : 0.0;

      // Return metrics
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
        debugPrint('getPatientProgressMetrics: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> getPatientHistoricalTrends(
    String patientId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final therapistId = _supabaseClient.auth.currentUser!.id;
      
      // Normalize dates to UTC
      final startOfRange = DateTime.utc(startDate.year, startDate.month, startDate.day, 0, 0, 0);
      final endOfRange = DateTime.utc(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
      
      // Verify therapist is assigned to this patient
      final assignment = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id')
          .eq('patient_id', patientId)
          .eq('therapist_id', therapistId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (assignment == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist is not assigned to this patient',
          statusCode: 403,
        );
      }

      // Fetch therapy goals for the date range
      final goalsResponse = await _supabaseClient
          .from('therapy_goal')
          .select('goals, observations, regressions, performed_on, therapy_type_id, therapy:therapy_type_id(name)')
          .eq('patient_id', patientId)
          .eq('therapist_id', therapistId)
          .gte('performed_on', startOfRange.toIso8601String())
          .lte('performed_on', endOfRange.toIso8601String())
          .order('performed_on', ascending: true);

      // Group by date and calculate daily metrics
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

      // Convert to list sorted by date
      final trendsList = trendsByDate.values.toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

      return ActionResultSuccess(data: trendsList, statusCode: 200);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getPatientHistoricalTrends: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> getExistingTherapyGoal(
    String patientId, {
    required DateTime date,
    required String therapyTypeId,
  }) async {
    try {
      final therapistId = _supabaseClient.auth.currentUser!.id;
      
      // Normalize date to UTC midnight
      final normalizedDate = DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
      final endOfDay = normalizedDate.add(const Duration(days: 1));
      
      // Fetch existing therapy goal
      final response = await _supabaseClient
          .from('therapy_goal')
          .select('*')
          .eq('patient_id', patientId)
          .eq('therapy_type_id', therapyTypeId)
          .eq('therapist_id', therapistId)
          .gte('performed_on', normalizedDate.toIso8601String())
          .lt('performed_on', endOfDay.toIso8601String())
          .maybeSingle();

      if (response == null) {
        return ActionResultFailure(
          errorMessage: 'No therapy goal found for this date and therapy type',
          statusCode: 404,
        );
      }

      return ActionResultSuccess(data: response, statusCode: 200);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getExistingTherapyGoal: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> getPatientActivityCompletion(
    String patientId, {
    String? activitySetId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final therapistId = _supabaseClient.auth.currentUser!.id;
      
      // Verify therapist is assigned to this patient
      final assignment = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('therapy_type_id')
          .eq('patient_id', patientId)
          .eq('therapist_id', therapistId)
          .eq('is_active', true)
          .limit(1)
          .maybeSingle();

      if (assignment == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist is not assigned to this patient',
          statusCode: 403,
        );
      }

      // First, get all activity sets created by this therapist for this patient
      var activitySetsQuery = _supabaseClient
          .from('daily_activities')
          .select('id')
          .eq('therapist_id', therapistId)
          .eq('patient_id', patientId);

      if (activitySetId != null) {
        activitySetsQuery = activitySetsQuery.eq('id', activitySetId);
      }

      final activitySets = await activitySetsQuery;
      final activitySetIds = activitySets.map((a) => a['id'] as String).toList();

      if (activitySetIds.isEmpty) {
        return ActionResultSuccess(data: <Map<String, dynamic>>[], statusCode: 200);
      }

      // Build query for daily_activity_logs
      var query = _supabaseClient
          .from('daily_activity_logs')
          .select('''
            *,
            activity:activity_id(
              id,
              activity_name,
              therapist_id,
              patient_id
            )
          ''')
          .eq('patient_id', patientId)
          .filter('activity_id', 'in', activitySetIds);

      // Filter by date range if provided
      if (startDate != null) {
        final startOfRange = DateTime.utc(startDate.year, startDate.month, startDate.day, 0, 0, 0);
        query = query.gte('date', startOfRange.toIso8601String());
      }

      if (endDate != null) {
        final endOfRange = DateTime.utc(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
        query = query.lte('date', endOfRange.toIso8601String());
      }

      final response = await query.order('date', ascending: false);

      if (kDebugMode) {
        debugPrint('getPatientActivityCompletion: Found ${response.length} logs');
        if (response.isEmpty) {
          debugPrint('getPatientActivityCompletion: No logs found for patient $patientId');
          debugPrint('getPatientActivityCompletion: Activity set IDs queried: $activitySetIds');
          debugPrint('getPatientActivityCompletion: Date range: ${startDate?.toIso8601String()} to ${endDate?.toIso8601String()}');
        }
      }

      // Process the response to extract completion data
      final List<Map<String, dynamic>> completionData = [];
      
      for (final log in response) {
        final activity = log['activity'] as Map<String, dynamic>?;
        if (activity == null) {
          if (kDebugMode) {
            debugPrint('getPatientActivityCompletion: Skipping log ${log['id']} - no activity data');
          }
          continue;
        }

        final activityItems = log['activity_items'] as List<dynamic>? ?? [];
        final parentNotes = log['parent_notes'] as List<dynamic>? ?? [];
        final date = log['date'] as String;
        
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
        
        int completedCount = 0;
        int totalCount = activityItems.length;
        final List<Map<String, dynamic>> items = [];

        for (final item in activityItems) {
          final itemData = item is String ? jsonDecode(item) : item;
          final isCompleted = itemData['is_completed'] as bool? ?? false;
          final activityId = itemData['id'] as String?;
          if (isCompleted) completedCount++;
          
          items.add({
            'id': activityId,
            'activity': itemData['activity'],
            'is_completed': isCompleted,
            'note': activityId != null ? notesMap[activityId] : null,
          });
        }

        completionData.add({
          'log_id': log['id'],
          'activity_set_id': log['activity_id'],
          'activity_set_name': activity['activity_name'] ?? 'Unknown',
          'date': date,
          'total_activities': totalCount,
          'completed_activities': completedCount,
          'completion_rate': totalCount > 0 ? (completedCount / totalCount) * 100 : 0.0,
          'items': items,
        });
      }

      return ActionResultSuccess(data: completionData, statusCode: 200);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('getPatientActivityCompletion: Error: $e');
      }
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 500,
      );
    }
  }

  @override
  Future<ActionResult> analyzeMilestones(String patientId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'analyze-milestones',
        body: {
          'patientId': patientId,
          'therapistId': _supabaseClient.auth.currentUser!.id,
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
