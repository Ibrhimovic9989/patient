import 'package:dart_mappable/dart_mappable.dart';

import '../../../model/daily_activities/daily_activity_response_model.dart';
import 'daily_activity_model.dart';

part 'daily_activity_response.mapper.dart';

@MappableClass()
class DailyActivityResponse with DailyActivityResponseMappable {

  @MappableField(key: 'id')
  final String id;
  @MappableField(key: 'created_at')
  final String createdAt;
  @MappableField(key: 'activity_name')
  final String activityName;
  @MappableField(key: 'activity_list')
  final List<DailyActivityModel> activityList;
  @MappableField(key: 'is_active')
  final bool isActive;
  @MappableField(key: 'patient_id')
  final String patientId;
  @MappableField(key: 'therapist_id')
  final String therapistId;
  @MappableField(key: 'start_time')
  final String startTime;
  @MappableField(key: 'end_time')
  final String endTime;
  @MappableField(key: 'days_of_week')
  final List<String> daysOfWeek;
  @MappableField(key: 'instructions')
  final Map<String, String>? instructions;
  @MappableField(key: 'reminder_settings')
  final Map<String, dynamic>? reminderSettings;

  DailyActivityResponse({
    required this.id,
    required this.createdAt,
    required this.activityName,
    required this.activityList,
    required this.isActive,
    required this.patientId,
    required this.therapistId,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.instructions,
    this.reminderSettings,
  });

  DailyActivityResponseModel toModel() {
    return DailyActivityResponseModel(
      id: id,
      createdAt: createdAt,
      activityName: activityName,
      activityList: activityList,
      isActive: isActive,
      patientId: patientId,
      therapistId: therapistId,
      startTime: startTime,
      endTime: endTime,
      daysOfWeek: daysOfWeek,
      instructions: instructions,
      reminderSettings: reminderSettings,
    );
  }
}