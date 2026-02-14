import 'package:flutter/material.dart';
import 'package:patient/core/core.dart';
import 'package:patient/core/repository/repository.dart';
import 'package:patient/core/utils/api_status_enum.dart';
import 'package:patient/model/progress_models/progress_metrics_model.dart';

class ProgressProvider extends ChangeNotifier {
  ProgressProvider({
    required PatientRepository patientRepository,
  }) : _patientRepository = patientRepository;

  final PatientRepository _patientRepository;

  ProgressMetricsModel? _progressMetrics;
  List<HistoricalTrendData> _historicalTrends = [];
  ApiStatus _apiStatus = ApiStatus.initial;
  String? _errorMessage;

  ProgressMetricsModel? get progressMetrics => _progressMetrics;
  List<HistoricalTrendData> get historicalTrends => _historicalTrends;
  ApiStatus get apiStatus => _apiStatus;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProgressMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? therapyTypeId,
  }) async {
    _apiStatus = ApiStatus.loading;
    notifyListeners();

    final result = await _patientRepository.getProgressMetrics(
      startDate: startDate,
      endDate: endDate,
      therapyTypeId: therapyTypeId,
    );

    if (result is ActionResultSuccess) {
      _progressMetrics = ProgressMetricsModel.fromMap(result.data as Map<String, dynamic>);
      _apiStatus = ApiStatus.success;
      _errorMessage = null;
    } else {
      _progressMetrics = null;
      _apiStatus = ApiStatus.failure;
      _errorMessage = result.errorMessage?.toString();
    }
    notifyListeners();
  }

  Future<void> fetchHistoricalTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? therapyTypeId,
  }) async {
    _apiStatus = ApiStatus.loading;
    notifyListeners();

    final result = await _patientRepository.getHistoricalTrends(
      startDate: startDate,
      endDate: endDate,
      therapyTypeId: therapyTypeId,
    );

    if (result is ActionResultSuccess) {
      final data = result.data as List<dynamic>;
      _historicalTrends = data.map((e) => HistoricalTrendData.fromMap(e as Map<String, dynamic>)).toList();
      _apiStatus = ApiStatus.success;
      _errorMessage = null;
    } else {
      _historicalTrends = [];
      _apiStatus = ApiStatus.failure;
      _errorMessage = result.errorMessage?.toString();
    }
    notifyListeners();
  }

  // Calculate week-over-week comparison
  Map<String, dynamic>? getWeekOverWeekComparison() {
    if (_progressMetrics == null) return null;

    // This would require fetching previous week's metrics
    // For now, return null - can be enhanced later
    return null;
  }

  // Calculate month-over-month comparison
  Map<String, dynamic>? getMonthOverMonthComparison() {
    if (_progressMetrics == null) return null;

    // This would require fetching previous month's metrics
    // For now, return null - can be enhanced later
    return null;
  }
}
