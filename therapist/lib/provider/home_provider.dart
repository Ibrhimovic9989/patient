import 'package:flutter/material.dart';
import 'package:therapist/core/repository/therapist/therapist_repository.dart';
import 'package:therapist/core/result/result.dart';
import 'package:therapist/core/utils/api_status_enum.dart';

class HomeProvider extends ChangeNotifier {
  final TherapistRepository _therapistRepository;

  HomeProvider({required TherapistRepository therapistRepository})
      : _therapistRepository = therapistRepository;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  int _totalPatients = 0;
  int get totalPatients => _totalPatients;

  int _totalSessions = 0;
  int get totalSessions => _totalSessions;

  int _totalTherapies = 0;
  int get totalTherapies => _totalTherapies;

  ApiStatus _statsStatus = ApiStatus.initial;
  ApiStatus get statsStatus => _statsStatus;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    _statsStatus = ApiStatus.loading;
    notifyListeners();

    try {
      // Fetch all stats in parallel
      final patientsResult = await _therapistRepository.getTotalPatients();
      final sessionsResult = await _therapistRepository.getTotalSessions();
      final therapiesResult = await _therapistRepository.getTotalTherapies();

      if (patientsResult is ActionResultSuccess) {
        _totalPatients = patientsResult.data as int;
      }

      if (sessionsResult is ActionResultSuccess) {
        _totalSessions = sessionsResult.data as int;
      }

      if (therapiesResult is ActionResultSuccess) {
        _totalTherapies = therapiesResult.data as int;
      }

      _statsStatus = ApiStatus.success;
    } catch (e) {
      _statsStatus = ApiStatus.failure;
    }

    notifyListeners();
  }
}
