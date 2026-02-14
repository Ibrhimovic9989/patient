import 'package:dart_mappable/dart_mappable.dart';

part 'patient_package_model.mapper.dart';

@MappableClass()
class PatientPackageModel with PatientPackageModelMappable {
  @MappableField(key: 'id')
  final String id;

  @MappableField(key: 'patient_id')
  final String patientId;

  @MappableField(key: 'package_id')
  final String packageId;

  @MappableField(key: 'clinic_id')
  final String clinicId;

  @MappableField(key: 'assigned_by')
  final String? assignedBy;

  @MappableField(key: 'assigned_at')
  final DateTime assignedAt;

  @MappableField(key: 'starts_at')
  final DateTime startsAt;

  @MappableField(key: 'expires_at')
  final DateTime? expiresAt;

  @MappableField(key: 'status')
  final String status;

  @MappableField(key: 'sessions_used')
  final Map<String, dynamic>? sessionsUsed;

  PatientPackageModel({
    required this.id,
    required this.patientId,
    required this.packageId,
    required this.clinicId,
    this.assignedBy,
    required this.assignedAt,
    required this.startsAt,
    this.expiresAt,
    required this.status,
    this.sessionsUsed,
  });
}
