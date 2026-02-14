import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:therapist/core/core.dart';
import 'package:therapist/model/model.dart';

enum SaveTherapyStatus {
  initial,
  loading,
  success,
  failure,
}

extension SaveTherapyStatusX on SaveTherapyStatus {
  bool get isInitial => this == SaveTherapyStatus.initial;
  bool get isLoading => this == SaveTherapyStatus.loading;
  bool get isSuccess => this == SaveTherapyStatus.success;
  bool get isFailure => this == SaveTherapyStatus.failure;
}

class TherapyProvider extends ChangeNotifier {

  TherapyProvider({
    required TherapyRepository therapyRepository,
  }) : _therapyRepository = therapyRepository;

  final TherapyRepository _therapyRepository;

  String? _patientId;
  String? get patientId => _patientId;

  List<TherapyTypeModel> _therapyTypes = [];
  List<TherapyTypeModel> get therapyTypes => _therapyTypes;

  String? _selectedTherapyType;
  String? get selectedTherapyType => _selectedTherapyType;

  DateTime? _selectedDateTime;
  DateTime? get selectedDateTime => _selectedDateTime;

  List<TherapyModel> _therapyGoals = [];
  List<TherapyModel> get therapyGoals => _therapyGoals;

  List<TherapyModel> _therapyObservations = [];
  List<TherapyModel> get therapyObservations => _therapyObservations;

  List<TherapyModel> _therapyRegressions = [];
  List<TherapyModel> get therapyRegressions => _therapyRegressions;

  List<TherapyModel> _therapyActivities = [];
  List<TherapyModel> get therapyActivities => _therapyActivities;

  List<TherapyModel> _selectedTherapyGoals = [];
  List<TherapyModel> get selectedTherapyGoals => _selectedTherapyGoals;

  List<TherapyModel> _selectedTherapyObservations = [];
  List<TherapyModel> get selectedTherapyObservations => _selectedTherapyObservations;

  List<TherapyModel> _selectedTherapyRegressions = [];
  List<TherapyModel> get selectedTherapyRegressions => _selectedTherapyRegressions;

  List<TherapyModel> _selectedTherapyActivities = [];
  List<TherapyModel> get selectedTherapyActivities => _selectedTherapyActivities;

  String? _sessionNotes;
  String? get sessionNotes => _sessionNotes;

  Map<String, String> _goalAchievementStatus = {};
  Map<String, String> get goalAchievementStatus => _goalAchievementStatus;

  SaveTherapyStatus _saveTherapyStatus = SaveTherapyStatus.initial;
  SaveTherapyStatus get saveTherapyStatus => _saveTherapyStatus;

  String _saveTherapyErrorMessage = '';
  String get saveTherapyErrorMessage => _saveTherapyErrorMessage;

  void getThearpyType({String? patientId}) async {
    if (patientId != null) {
      // Get therapy types filtered by patient's package
      await getTherapyTypesForPatient(patientId);
    } else {
      // Get all therapy types
      final ActionResult result = await _therapyRepository.getTherapyTypes();
      if(result is ActionResultSuccess) {
        _therapyTypes = result.data;
        notifyListeners();
      } else {
        _therapyTypes = [];
        notifyListeners();
      }
    }
  }

  Future<void> getTherapyTypesForPatient(String patientId) async {
    if (kDebugMode) {
      debugPrint('TherapyProvider: Fetching therapy types for patient: $patientId');
    }
    final ActionResult result = await _therapyRepository.getTherapyTypesForPatient(patientId);
    if(result is ActionResultSuccess) {
      _therapyTypes = result.data;
      if (kDebugMode) {
        debugPrint('TherapyProvider: Successfully loaded ${_therapyTypes.length} therapy types');
        if (_therapyTypes.isNotEmpty) {
          debugPrint('TherapyProvider: First therapy type - ID: ${_therapyTypes.first.therapyId}, Name: ${_therapyTypes.first.name}');
        }
      }
      notifyListeners();
    } else {
      _therapyTypes = [];
      if (kDebugMode) {
        debugPrint('TherapyProvider: Failed to load therapy types. Error: ${result is ActionResultFailure ? result.errorMessage : 'Unknown error'}');
      }
      notifyListeners();
    }
  }

  set setPatientId(String patientId) {
    _patientId = patientId;
    notifyListeners();
  }

  set setSelectedTherapyType(String therapyType) {
    _selectedTherapyType = therapyType;
    _selectedTherapyActivities = [];
    _selectedTherapyGoals = [];
    _selectedTherapyObservations = [];
    _selectedTherapyRegressions = [];
    _sessionNotes = null;
    _goalAchievementStatus = {};
    notifyListeners();
    // Load existing data if date is also selected
    if (_selectedDateTime != null && _patientId != null) {
      _loadExistingTherapyGoal();
    }
  }

  setSelectedDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    notifyListeners();
    // Load existing data if therapy type is also selected
    if (_selectedTherapyType != null && _selectedTherapyType!.isNotEmpty && _patientId != null) {
      _loadExistingTherapyGoal();
    }
  }

  Future<void> _loadExistingTherapyGoal() async {
    if (_patientId == null || _selectedDateTime == null || _selectedTherapyType == null || _selectedTherapyType!.isEmpty) {
      return;
    }

    try {
      final result = await _therapyRepository.getExistingTherapyGoal(
        _patientId!,
        date: _selectedDateTime!,
        therapyTypeId: _selectedTherapyType!,
      );

      if (result is ActionResultSuccess) {
        final data = result.data as Map<String, dynamic>;
        
        // Parse goals
        final goalsData = data['goals'] as List<dynamic>? ?? [];
        _selectedTherapyGoals = goalsData.map((g) {
          return TherapyModel(
            id: g['id'] as String,
            name: g['name'] as String,
          );
        }).toList();

        // Parse observations
        final observationsData = data['observations'] as List<dynamic>? ?? [];
        _selectedTherapyObservations = observationsData.map((o) {
          return TherapyModel(
            id: o['id'] as String,
            name: o['name'] as String,
          );
        }).toList();

        // Parse regressions
        final regressionsData = data['regressions'] as List<dynamic>? ?? [];
        _selectedTherapyRegressions = regressionsData.map((r) {
          return TherapyModel(
            id: r['id'] as String,
            name: r['name'] as String,
          );
        }).toList();

        // Parse activities
        final activitiesData = data['activities'] as List<dynamic>? ?? [];
        _selectedTherapyActivities = activitiesData.map((a) {
          return TherapyModel(
            id: a['id'] as String,
            name: a['name'] as String,
          );
        }).toList();

        // Parse session notes
        _sessionNotes = data['session_notes'] as String?;

        // Parse goal achievement status
        final achievementStatusData = data['goal_achievement_status'] as Map<String, dynamic>?;
        if (achievementStatusData != null) {
          _goalAchievementStatus = achievementStatusData.map((key, value) => MapEntry(key, value.toString()));
        } else {
          _goalAchievementStatus = {};
        }

        notifyListeners();
      } else {
        // No existing data found, clear selections
        _selectedTherapyGoals = [];
        _selectedTherapyObservations = [];
        _selectedTherapyRegressions = [];
        _selectedTherapyActivities = [];
        _sessionNotes = null;
        _goalAchievementStatus = {};
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('_loadExistingTherapyGoal: Error loading existing data: $e');
      }
      // On error, clear selections
      _selectedTherapyGoals = [];
      _selectedTherapyObservations = [];
      _selectedTherapyRegressions = [];
      _selectedTherapyActivities = [];
      _sessionNotes = null;
      _goalAchievementStatus = {};
      notifyListeners();
    }
  }

  String _getTherapyIdFromSelectedTherapy() {
    // _selectedTherapyType now stores the therapy ID directly
    if (_selectedTherapyType == null || _selectedTherapyType!.isEmpty) {
      throw Exception('No therapy type selected');
    }
    return _selectedTherapyType!;
  }

  void addTherapyGoals(String goal) async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    await _therapyRepository.addTherapyGoals(therapyId,goal);
    notifyListeners();
  }

  void addTherapyObservations(String observation) async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    await _therapyRepository.addTherapyObservations(therapyId, observation);
    notifyListeners();
  }

  void addTherapyRegressions(String regression) async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    await _therapyRepository.addTherapyRegressions(therapyId, regression);
  }

  void addTherapyActivities(String activity) async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    await _therapyRepository.addTherapyActivities(therapyId, activity);
  }

  void getTherapyGoals() async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    final ActionResult result = await _therapyRepository.getAllGoals(therapyId);
    if(result is ActionResultSuccess) {
      _therapyGoals = result.data;
      notifyListeners();
    } else {
      _therapyGoals = [];
      notifyListeners();
    }
  }

  void getTherapyObservations() async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    final ActionResult result = await _therapyRepository.getAllObservations(therapyId);
    if(result is ActionResultSuccess) {
      _therapyObservations = result.data;
      notifyListeners();
    } else {
      _therapyObservations = [];
      notifyListeners();
    }
  }

  void getTherapyRegressions() async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    final ActionResult result = await _therapyRepository.getAllRegressions(therapyId);
    if(result is ActionResultSuccess) {
      _therapyRegressions = result.data;
      notifyListeners();
    } else {
      _therapyRegressions = [];
      notifyListeners();
    }
  }

  void getTherapyActivities() async {
    final therapyId = _getTherapyIdFromSelectedTherapy();
    final ActionResult result = await _therapyRepository.getAllActivities(therapyId);
    if(result is ActionResultSuccess) {
      _therapyActivities = result.data;
      notifyListeners();
    } else {
      _therapyActivities = [];
      notifyListeners();
    }
  }

  void resetTherapyData() {
    _therapyGoals = [];
    _therapyObservations = [];
    _therapyRegressions = [];
    _therapyActivities = [];
    notifyListeners();
  }

  void addToSelectedGoals(TherapyModel therapyModel) {
    _selectedTherapyGoals.add(therapyModel);
    notifyListeners();
  }

  void removeFromSelectedGoals(TherapyModel therapyModel) {
    _selectedTherapyGoals.removeWhere((element) => element.id == therapyModel.id);
    notifyListeners();
  }

  void addToSelectedObservations(TherapyModel therapyModel) {
    _selectedTherapyObservations.add(therapyModel);
    notifyListeners();
  }
  
  void removeFromSelectedObservations(TherapyModel therapyModel) {
    _selectedTherapyObservations.removeWhere((element) => element.id == therapyModel.id);
    notifyListeners();
  }

  void addToSelectedRegressions(TherapyModel therapyModel) {
    _selectedTherapyRegressions.add(therapyModel);
    notifyListeners();
  }

  void removeFromSelectedRegressions(TherapyModel therapyModel) {
    _selectedTherapyRegressions.removeWhere((element) => element.id == therapyModel.id);
    notifyListeners();
  }

  void addToSelectedActivities(TherapyModel therapyModel) {
    _selectedTherapyActivities.add(therapyModel);
    notifyListeners();
  }

  void removeFromSelectedActivities(TherapyModel therapyModel) {
    _selectedTherapyActivities.removeWhere((element) => element.id == therapyModel.id);
    notifyListeners();
  }

  void saveTherapyDetails() async {
    // Validate required fields
    if (_patientId == null || _patientId!.isEmpty) {
      _saveTherapyStatus = SaveTherapyStatus.failure;
      _saveTherapyErrorMessage = 'Patient ID is required';
      notifyListeners();
      return;
    }
    
    if (_selectedTherapyType == null || _selectedTherapyType!.isEmpty) {
      _saveTherapyStatus = SaveTherapyStatus.failure;
      _saveTherapyErrorMessage = 'Please select a therapy type';
      notifyListeners();
      return;
    }
    
    if (_selectedDateTime == null) {
      _saveTherapyStatus = SaveTherapyStatus.failure;
      _saveTherapyErrorMessage = 'Please select a therapy date';
      notifyListeners();
      return;
    }
    
    if (kDebugMode) {
      debugPrint('saveTherapyDetails: Starting save');
      debugPrint('saveTherapyDetails: Patient ID: $_patientId');
      debugPrint('saveTherapyDetails: Therapy Type ID: ${_getTherapyIdFromSelectedTherapy()}');
      debugPrint('saveTherapyDetails: Date: $_selectedDateTime');
      debugPrint('saveTherapyDetails: Goals count: ${_selectedTherapyGoals.length}');
      debugPrint('saveTherapyDetails: Observations count: ${_selectedTherapyObservations.length}');
      debugPrint('saveTherapyDetails: Regressions count: ${_selectedTherapyRegressions.length}');
      debugPrint('saveTherapyDetails: Activities count: ${_selectedTherapyActivities.length}');
    }
    
    _saveTherapyStatus = SaveTherapyStatus.loading;
    notifyListeners();
    
    try {
      // Normalize the date to UTC midnight to avoid timezone issues
      // Extract only the date components (year, month, day) and create UTC date
      final selectedDate = _selectedDateTime!;
      final normalizedDate = DateTime.utc(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        0, // hour
        0, // minute
        0, // second
      );
      
      if (kDebugMode) {
        debugPrint('saveTherapyDetails: Original date: $selectedDate');
        debugPrint('saveTherapyDetails: Normalized UTC date: $normalizedDate');
      }
      
      final therapyGoalModel = TherapyGoalModel(
        performedOn: normalizedDate,
        therapyTypeId: _getTherapyIdFromSelectedTherapy(),
        goals: _selectedTherapyGoals,
        observations: _selectedTherapyObservations,
        regressions: _selectedTherapyRegressions,
        activities: _selectedTherapyActivities,
        patientId: _patientId,
        sessionNotes: _sessionNotes,
        goalAchievementStatus: _goalAchievementStatus.isEmpty ? null : _goalAchievementStatus,
      );

      final ActionResult result = await _therapyRepository.saveTherapyGoals(therapyGoalModel.toEntity());

      if(result is ActionResultSuccess) {
        _saveTherapyStatus = SaveTherapyStatus.success;
        _saveTherapyErrorMessage = '';
        if (kDebugMode) {
          debugPrint('saveTherapyDetails: Successfully saved');
        }
        notifyListeners();
      } else {
        _saveTherapyStatus = SaveTherapyStatus.failure;
        _saveTherapyErrorMessage = result.errorMessage?.toString() ?? 'Failed to save therapy details';
        if (kDebugMode) {
          debugPrint('saveTherapyDetails: Failed - ${_saveTherapyErrorMessage}');
        }
        notifyListeners();
      }
    } catch (e, stackTrace) {
      _saveTherapyStatus = SaveTherapyStatus.failure;
      _saveTherapyErrorMessage = 'Error: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('saveTherapyDetails: Exception - $e');
        debugPrint('saveTherapyDetails: Stack trace - $stackTrace');
      }
      notifyListeners();
    }
  }

  void setSessionNotes(String? notes) {
    _sessionNotes = notes;
    notifyListeners();
  }

  void setGoalAchievementStatus(String goalId, String status) {
    _goalAchievementStatus[goalId] = status;
    notifyListeners();
  }

  void resetAllFields() {
    _patientId = null;
    _therapyTypes = [];
    _selectedTherapyType = null;
    _selectedDateTime = null;
    _therapyGoals = [];
    _therapyObservations = [];
    _therapyRegressions = [];
    _therapyActivities = [];
    _selectedTherapyGoals = [];
    _selectedTherapyObservations = [];
    _selectedTherapyRegressions = [];
    _selectedTherapyActivities = [];
    _sessionNotes = null;
    _goalAchievementStatus = {};
    _saveTherapyStatus = SaveTherapyStatus.initial;
    _saveTherapyErrorMessage = '';
    notifyListeners();
  }



}