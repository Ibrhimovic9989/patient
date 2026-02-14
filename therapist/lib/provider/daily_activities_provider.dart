import 'package:flutter/material.dart';
import 'package:therapist/core/result/action_result_success.dart';
import 'package:therapist/core/utils/api_status_enum.dart';
import 'package:therapist/model/daily_activities/daily_activity_response_model.dart';

import '../core/repository/therapy/therapy_repository.dart';

class DailyActivitiesProvider extends ChangeNotifier {

  DailyActivitiesProvider({
    required TherapyRepository therapyRepository,
  }) : _therapyRepository = therapyRepository;

  final TherapyRepository _therapyRepository;

  
  ApiStatus _dailyActivitiesStatus = ApiStatus.initial;

  ApiStatus get dailyActivitiesStatus => _dailyActivitiesStatus;

  List<DailyActivityResponseModel> _dailyActivities = [];

  List<DailyActivityResponseModel> get dailyActivities => _dailyActivities;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  ApiStatus _addActivitySetStatus = ApiStatus.initial;
  ApiStatus get addActivitySetStatus => _addActivitySetStatus;

  ApiStatus _deleteActivitySetStatus = ApiStatus.initial;
  ApiStatus get deleteActivitySetStatus => _deleteActivitySetStatus;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> deleteActivitySet(String activitySetId, String patientId) async {
    try {
      _deleteActivitySetStatus = ApiStatus.loading;
      final result = await _therapyRepository.deleteDailyActivity(activitySetId);
      if(result is ActionResultSuccess) {
        _deleteActivitySetStatus = ApiStatus.success;
        getDailyActivities(patientId);
      } else {
        _deleteActivitySetStatus = ApiStatus.failure;
      }
      notifyListeners();
    } catch (e) {
      _deleteActivitySetStatus = ApiStatus.failure;
    }
  }

  Future<void> addOrUpdateActivitySet(
    DailyActivityResponseModel activitySet, {
    String? patientId,
  }) async {
    try {
      _addActivitySetStatus = ApiStatus.loading;
      notifyListeners();
      final result = await _therapyRepository.addOrUpdateDailyActivity(activitySet.toEntity());
      if(result is ActionResultSuccess) {
        _addActivitySetStatus = ApiStatus.success;
        _errorMessage = null;
        // Refresh the list if patientId is provided
        if (patientId != null) {
          await getDailyActivities(patientId);
        }
      } else {
        _addActivitySetStatus = ApiStatus.failure;
        _errorMessage = result.errorMessage?.toString() ?? 'Failed to save activity set';
      }
      notifyListeners();
    } catch (e) {
      _addActivitySetStatus = ApiStatus.failure;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDailyActivities(String patientId) async {
    try {
      _dailyActivitiesStatus = ApiStatus.loading;
      notifyListeners();
      final result = await _therapyRepository.getAllDailyActivities(patientId);
      if(result is ActionResultSuccess) {
        _dailyActivities = result.data as List<DailyActivityResponseModel>;
        _dailyActivitiesStatus = ApiStatus.success;
      } else {
        _dailyActivitiesStatus = ApiStatus.failure;
      }
      notifyListeners();
    } catch (e) {
      _dailyActivitiesStatus = ApiStatus.failure;
    } finally {
      notifyListeners();
    }
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  // Activity Completion Tracking
  ApiStatus _activityCompletionStatus = ApiStatus.initial;
  ApiStatus get activityCompletionStatus => _activityCompletionStatus;

  List<Map<String, dynamic>> _activityCompletionData = [];
  List<Map<String, dynamic>> get activityCompletionData => _activityCompletionData;

  String? _activityCompletionError;
  String? get activityCompletionError => _activityCompletionError;

  Future<void> getPatientActivityCompletion(
    String patientId, {
    String? activitySetId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _activityCompletionStatus = ApiStatus.loading;
      _activityCompletionError = null;
      notifyListeners();

      final result = await _therapyRepository.getPatientActivityCompletion(
        patientId,
        activitySetId: activitySetId,
        startDate: startDate,
        endDate: endDate,
      );

      if (result is ActionResultSuccess) {
        _activityCompletionData = (result.data as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        _activityCompletionStatus = ApiStatus.success;
      } else {
        _activityCompletionData = [];
        _activityCompletionStatus = ApiStatus.failure;
        _activityCompletionError = result.errorMessage?.toString();
      }
      notifyListeners();
    } catch (e) {
      _activityCompletionData = [];
      _activityCompletionStatus = ApiStatus.failure;
      _activityCompletionError = e.toString();
      notifyListeners();
    }
  }
}