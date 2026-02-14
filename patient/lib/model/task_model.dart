import 'package:dart_mappable/dart_mappable.dart';

part 'task_model.mapper.dart';

@MappableClass()
class PatientTaskModel with PatientTaskModelMappable {
  @MappableField(key: 'id')
  final String? activityId;
  @MappableField(key: 'activity')
  final String? activityName;
  @MappableField(key: 'is_completed')
  final bool? isCompleted;
  @MappableField(key: 'note')
  final String? note;
  @MappableField(key: 'instructions')
  final String? instructions;
  @MappableField(key: 'media_attachments')
  final List<Map<String, dynamic>>? mediaAttachments;

  PatientTaskModel({
    this.activityId,
    this.activityName,
    this.isCompleted = false,
    this.note,
    this.instructions,
    this.mediaAttachments,
  });

  static const fromMap = PatientTaskModelMapper.fromMap;
  static const fromJson = PatientTaskModelMapper.fromJson;

}
