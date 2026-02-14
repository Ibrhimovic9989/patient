import 'package:dart_mappable/dart_mappable.dart';

part 'milestone_insight_model.mapper.dart';

@MappableClass()
class MilestoneInsightModel with MilestoneInsightModelMappable {
  final String title;
  final String category; // motor, cognitive, social, communication, behavioral, self_care
  final String status; // achieved, in_progress, regressed
  final String description;
  final String evidence;

  MilestoneInsightModel({
    required this.title,
    required this.category,
    required this.status,
    required this.description,
    required this.evidence,
  });
}

@MappableClass()
class MilestoneAnalysisModel with MilestoneAnalysisModelMappable {
  final List<MilestoneInsightModel> milestones;
  final String progressSummary;
  final MilestoneTrendsModel trends;
  final List<String> recommendations;

  MilestoneAnalysisModel({
    required this.milestones,
    required this.progressSummary,
    required this.trends,
    required this.recommendations,
  });
}

@MappableClass()
class MilestoneTrendsModel with MilestoneTrendsModelMappable {
  final List<String> improving;
  final List<String> stable;
  final List<String> concerning;

  MilestoneTrendsModel({
    required this.improving,
    required this.stable,
    required this.concerning,
  });
}
