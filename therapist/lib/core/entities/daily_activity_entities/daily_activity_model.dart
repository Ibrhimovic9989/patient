import 'package:dart_mappable/dart_mappable.dart';

part 'daily_activity_model.mapper.dart';

@MappableClass()
class DailyActivityModel with DailyActivityModelMappable {

  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'activity')
  final String activity;

  @MappableField(key: 'is_completed')
  final bool isCompleted;

  @MappableField(key: 'instructions')
  final String? instructions;

  DailyActivityModel({
    required this.id,
    required this.activity,
    required this.isCompleted,
    this.instructions,
  });
}
