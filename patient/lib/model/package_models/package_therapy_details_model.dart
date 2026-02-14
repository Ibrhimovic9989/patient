import 'package:dart_mappable/dart_mappable.dart';

part 'package_therapy_details_model.mapper.dart';

@MappableClass()
class PackageTherapyDetailsModel with PackageTherapyDetailsModelMappable {
  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'therapy_type_id')
  final String therapyTypeId;

  @MappableField(key: 'therapy_name')
  final String? therapyName; // Joined from therapy table

  @MappableField(key: 'session_count')
  final int sessionCount;

  @MappableField(key: 'frequency_per_week')
  final int? frequencyPerWeek;

  @MappableField(key: 'session_duration_minutes')
  final int? sessionDurationMinutes;

  PackageTherapyDetailsModel({
    required this.id,
    required this.therapyTypeId,
    this.therapyName,
    required this.sessionCount,
    this.frequencyPerWeek,
    this.sessionDurationMinutes,
  });
}
