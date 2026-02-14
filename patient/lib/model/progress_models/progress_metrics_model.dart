class ProgressMetricsModel {
  final int goalsAchieved;
  final int totalGoals;
  final double goalsAchievementRate;
  final int observationsCount;
  final int regressionsCount;
  final int sessionsCount;
  final double attendanceRate;
  final DateTime startDate;
  final DateTime endDate;

  ProgressMetricsModel({
    required this.goalsAchieved,
    required this.totalGoals,
    required this.goalsAchievementRate,
    required this.observationsCount,
    required this.regressionsCount,
    required this.sessionsCount,
    required this.attendanceRate,
    required this.startDate,
    required this.endDate,
  });

  factory ProgressMetricsModel.fromMap(Map<String, dynamic> map) {
    return ProgressMetricsModel(
      goalsAchieved: map['goalsAchieved'] as int? ?? 0,
      totalGoals: map['totalGoals'] as int? ?? 0,
      goalsAchievementRate: (map['goalsAchievementRate'] as num?)?.toDouble() ?? 0.0,
      observationsCount: map['observationsCount'] as int? ?? 0,
      regressionsCount: map['regressionsCount'] as int? ?? 0,
      sessionsCount: map['sessionsCount'] as int? ?? 0,
      attendanceRate: (map['attendanceRate'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
    );
  }
}

class HistoricalTrendData {
  final String date;
  final int goalsCount;
  final int observationsCount;
  final int regressionsCount;
  final List<String> therapyTypes;

  HistoricalTrendData({
    required this.date,
    required this.goalsCount,
    required this.observationsCount,
    required this.regressionsCount,
    required this.therapyTypes,
  });

  factory HistoricalTrendData.fromMap(Map<String, dynamic> map) {
    return HistoricalTrendData(
      date: map['date'] as String,
      goalsCount: map['goalsCount'] as int? ?? 0,
      observationsCount: map['observationsCount'] as int? ?? 0,
      regressionsCount: map['regressionsCount'] as int? ?? 0,
      therapyTypes: (map['therapyTypes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
