import 'package:flutter/material.dart';
import 'package:patient/core/core.dart';
import 'package:patient/core/repository/repository.dart';
import 'package:patient/core/utils/utils.dart';

import '../model/therapy_models/therapy_models.dart';

class TherapyGoalsProvider extends ChangeNotifier {

  TherapyGoalsProvider({
    required PatientRepository patientRepository,
  }): _patientRepository = patientRepository;

  final PatientRepository _patientRepository;

  TherapyGoalModel? _therapyGoal;
  ApiStatus _apiStatus = ApiStatus.initial;
  List<TherapyTypeModel> _therapyTypes = [];
  List<Map<String, dynamic>> _appointments = [];
  String? _selectedTherapyTypeId;

  TherapyGoalModel? get therapyGoal => _therapyGoal;
  ApiStatus get apiStatus => _apiStatus;
  List<TherapyTypeModel> get therapyTypes => _therapyTypes;
  List<Map<String, dynamic>> get appointments => _appointments;
  String? get selectedTherapyTypeId => _selectedTherapyTypeId;

  void setSelectedTherapyTypeId(String? therapyTypeId) {
    _selectedTherapyTypeId = therapyTypeId;
    notifyListeners();
  }

  Future<void> loadTherapyTypes() async {
    final result = await _patientRepository.getTherapyTypesForPackage();
    if (result is ActionResultSuccess) {
      _therapyTypes = result.data as List<TherapyTypeModel>;
      notifyListeners();
    } else {
      _therapyTypes = [];
      notifyListeners();
    }
  }

  void fetchTherapyGoals(DateTime date) async {
    _apiStatus = ApiStatus.loading;
    notifyListeners();

    final result = await _patientRepository.getTherapyGoals(
      date: date,
      therapyTypeId: _selectedTherapyTypeId,
    );

    if (result is ActionResultSuccess) {
      _therapyGoal = result.data as TherapyGoalModel;
      _apiStatus = ApiStatus.success;
      // Also fetch appointments for this date
      await _loadAppointmentsForDate(date);
      notifyListeners();
    } else {
      _therapyGoal = null;
      _apiStatus = ApiStatus.failure;
      // Even if no goals, try to load appointments
      await _loadAppointmentsForDate(date);
      notifyListeners();
    }
  }

  Future<void> _loadAppointmentsForDate(DateTime date) async {
    final result = await _patientRepository.getAppointmentsForDate(date);
    if (result is ActionResultSuccess) {
      _appointments = result.data as List<Map<String, dynamic>>;
    } else {
      _appointments = [];
    }
    notifyListeners();
  }
}