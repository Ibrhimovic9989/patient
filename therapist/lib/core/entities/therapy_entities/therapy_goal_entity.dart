import 'package:dart_mappable/dart_mappable.dart';
import 'package:therapist/model/therapy_models/therapy_model.dart';

part 'therapy_goal_entity.mapper.dart';

@MappableClass()
class TherapyGoalEntity with TherapyGoalEntityMappable {

  @MappableField(key: 'performed_on')
  final DateTime performedOn;

  @MappableField(key: 'therapist_id')
  final String? therapistId;

  @MappableField(key: 'therapy_type_id')
  final String therapyTypeId;

  @MappableField(key: 'goals')
  final List<TherapyModel> goals;

  @MappableField(key: 'observations')
  final List<TherapyModel> observations;

  @MappableField(key: 'regressions')
  final List<TherapyModel> regressions;

  @MappableField(key: 'activities')
  final List<TherapyModel> activities;

  @MappableField(key: 'patient_id')
  final String? patientId;

  @MappableField(key: 'package_id')
  final String? packageId;

  @MappableField(key: 'patient_package_id')
  final String? patientPackageId;

  @MappableField(key: 'session_notes')
  final String? sessionNotes;

  @MappableField(key: 'goal_achievement_status')
  final Map<String, String>? goalAchievementStatus;

  TherapyGoalEntity({
    this.patientId,
    required this.performedOn,
    this.therapistId,
    required this.therapyTypeId,
    required this.goals,
    required this.observations,
    required this.regressions,
    required this.activities,
    this.packageId,
    this.patientPackageId,
    this.sessionNotes,
    this.goalAchievementStatus,
  });
}