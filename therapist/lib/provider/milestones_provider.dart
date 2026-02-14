import 'package:flutter/foundation.dart';
import 'package:therapist/core/core.dart';
import 'package:therapist/core/utils/api_status_enum.dart';
import 'package:therapist/model/milestones/milestone_insight_model.dart';

class MilestonesProvider with ChangeNotifier {
  final TherapyRepository _therapyRepository;
  
  ApiStatus _apiStatus = ApiStatus.initial;
  ApiStatus get apiStatus => _apiStatus;
  
  MilestoneAnalysisModel? _analysis;
  MilestoneAnalysisModel? get analysis => _analysis;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MilestonesProvider({
    required TherapyRepository therapyRepository,
  }) : _therapyRepository = therapyRepository;

  Future<void> analyzeMilestones(String patientId) async {
    try {
      _apiStatus = ApiStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _therapyRepository.analyzeMilestones(patientId);

      if (result is ActionResultSuccess) {
        try {
          _analysis = MilestoneAnalysisModelMapper.fromMap(result.data);
          _apiStatus = ApiStatus.success;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('MilestonesProvider: Error parsing analysis data: $e');
            debugPrint('MilestonesProvider: Data: ${result.data}');
          }
          _errorMessage = 'Failed to parse milestone analysis';
          _apiStatus = ApiStatus.failure;
        }
      } else {
        _errorMessage = result.errorMessage;
        _apiStatus = ApiStatus.failure;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _apiStatus = ApiStatus.failure;
      notifyListeners();
    }
  }
}
