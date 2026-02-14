// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'patient_package_model.dart';

class PatientPackageModelMapper extends ClassMapperBase<PatientPackageModel> {
  PatientPackageModelMapper._();

  static PatientPackageModelMapper? _instance;
  static PatientPackageModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PatientPackageModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PatientPackageModel';

  static String _$id(PatientPackageModel v) => v.id;
  static const Field<PatientPackageModel, String> _f$id = Field('id', _$id);
  static String _$patientId(PatientPackageModel v) => v.patientId;
  static const Field<PatientPackageModel, String> _f$patientId =
      Field('patientId', _$patientId, key: r'patient_id');
  static String _$packageId(PatientPackageModel v) => v.packageId;
  static const Field<PatientPackageModel, String> _f$packageId =
      Field('packageId', _$packageId, key: r'package_id');
  static String _$clinicId(PatientPackageModel v) => v.clinicId;
  static const Field<PatientPackageModel, String> _f$clinicId =
      Field('clinicId', _$clinicId, key: r'clinic_id');
  static String? _$assignedBy(PatientPackageModel v) => v.assignedBy;
  static const Field<PatientPackageModel, String> _f$assignedBy =
      Field('assignedBy', _$assignedBy, key: r'assigned_by', opt: true);
  static DateTime _$assignedAt(PatientPackageModel v) => v.assignedAt;
  static const Field<PatientPackageModel, DateTime> _f$assignedAt =
      Field('assignedAt', _$assignedAt, key: r'assigned_at');
  static DateTime _$startsAt(PatientPackageModel v) => v.startsAt;
  static const Field<PatientPackageModel, DateTime> _f$startsAt =
      Field('startsAt', _$startsAt, key: r'starts_at');
  static DateTime? _$expiresAt(PatientPackageModel v) => v.expiresAt;
  static const Field<PatientPackageModel, DateTime> _f$expiresAt =
      Field('expiresAt', _$expiresAt, key: r'expires_at', opt: true);
  static String _$status(PatientPackageModel v) => v.status;
  static const Field<PatientPackageModel, String> _f$status =
      Field('status', _$status);
  static Map<String, dynamic>? _$sessionsUsed(PatientPackageModel v) =>
      v.sessionsUsed;
  static const Field<PatientPackageModel, Map<String, dynamic>>
      _f$sessionsUsed =
      Field('sessionsUsed', _$sessionsUsed, key: r'sessions_used', opt: true);

  @override
  final MappableFields<PatientPackageModel> fields = const {
    #id: _f$id,
    #patientId: _f$patientId,
    #packageId: _f$packageId,
    #clinicId: _f$clinicId,
    #assignedBy: _f$assignedBy,
    #assignedAt: _f$assignedAt,
    #startsAt: _f$startsAt,
    #expiresAt: _f$expiresAt,
    #status: _f$status,
    #sessionsUsed: _f$sessionsUsed,
  };

  static PatientPackageModel _instantiate(DecodingData data) {
    return PatientPackageModel(
        id: data.dec(_f$id),
        patientId: data.dec(_f$patientId),
        packageId: data.dec(_f$packageId),
        clinicId: data.dec(_f$clinicId),
        assignedBy: data.dec(_f$assignedBy),
        assignedAt: data.dec(_f$assignedAt),
        startsAt: data.dec(_f$startsAt),
        expiresAt: data.dec(_f$expiresAt),
        status: data.dec(_f$status),
        sessionsUsed: data.dec(_f$sessionsUsed));
  }

  @override
  final Function instantiate = _instantiate;

  static PatientPackageModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PatientPackageModel>(map);
  }

  static PatientPackageModel fromJson(String json) {
    return ensureInitialized().decodeJson<PatientPackageModel>(json);
  }
}

mixin PatientPackageModelMappable {
  String toJson() {
    return PatientPackageModelMapper.ensureInitialized()
        .encodeJson<PatientPackageModel>(this as PatientPackageModel);
  }

  Map<String, dynamic> toMap() {
    return PatientPackageModelMapper.ensureInitialized()
        .encodeMap<PatientPackageModel>(this as PatientPackageModel);
  }

  PatientPackageModelCopyWith<PatientPackageModel, PatientPackageModel,
      PatientPackageModel> get copyWith => _PatientPackageModelCopyWithImpl<
          PatientPackageModel, PatientPackageModel>(
      this as PatientPackageModel, $identity, $identity);
  @override
  String toString() {
    return PatientPackageModelMapper.ensureInitialized()
        .stringifyValue(this as PatientPackageModel);
  }

  @override
  bool operator ==(Object other) {
    return PatientPackageModelMapper.ensureInitialized()
        .equalsValue(this as PatientPackageModel, other);
  }

  @override
  int get hashCode {
    return PatientPackageModelMapper.ensureInitialized()
        .hashValue(this as PatientPackageModel);
  }
}

extension PatientPackageModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PatientPackageModel, $Out> {
  PatientPackageModelCopyWith<$R, PatientPackageModel, $Out>
      get $asPatientPackageModel => $base.as(
          (v, t, t2) => _PatientPackageModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PatientPackageModelCopyWith<$R, $In extends PatientPackageModel,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get sessionsUsed;
  $R call(
      {String? id,
      String? patientId,
      String? packageId,
      String? clinicId,
      String? assignedBy,
      DateTime? assignedAt,
      DateTime? startsAt,
      DateTime? expiresAt,
      String? status,
      Map<String, dynamic>? sessionsUsed});
  PatientPackageModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PatientPackageModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PatientPackageModel, $Out>
    implements PatientPackageModelCopyWith<$R, PatientPackageModel, $Out> {
  _PatientPackageModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PatientPackageModel> $mapper =
      PatientPackageModelMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
      get sessionsUsed => $value.sessionsUsed != null
          ? MapCopyWith(
              $value.sessionsUsed!,
              (v, t) => ObjectCopyWith(v, $identity, t),
              (v) => call(sessionsUsed: v))
          : null;
  @override
  $R call(
          {String? id,
          String? patientId,
          String? packageId,
          String? clinicId,
          Object? assignedBy = $none,
          DateTime? assignedAt,
          DateTime? startsAt,
          Object? expiresAt = $none,
          String? status,
          Object? sessionsUsed = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (patientId != null) #patientId: patientId,
        if (packageId != null) #packageId: packageId,
        if (clinicId != null) #clinicId: clinicId,
        if (assignedBy != $none) #assignedBy: assignedBy,
        if (assignedAt != null) #assignedAt: assignedAt,
        if (startsAt != null) #startsAt: startsAt,
        if (expiresAt != $none) #expiresAt: expiresAt,
        if (status != null) #status: status,
        if (sessionsUsed != $none) #sessionsUsed: sessionsUsed
      }));
  @override
  PatientPackageModel $make(CopyWithData data) => PatientPackageModel(
      id: data.get(#id, or: $value.id),
      patientId: data.get(#patientId, or: $value.patientId),
      packageId: data.get(#packageId, or: $value.packageId),
      clinicId: data.get(#clinicId, or: $value.clinicId),
      assignedBy: data.get(#assignedBy, or: $value.assignedBy),
      assignedAt: data.get(#assignedAt, or: $value.assignedAt),
      startsAt: data.get(#startsAt, or: $value.startsAt),
      expiresAt: data.get(#expiresAt, or: $value.expiresAt),
      status: data.get(#status, or: $value.status),
      sessionsUsed: data.get(#sessionsUsed, or: $value.sessionsUsed));

  @override
  PatientPackageModelCopyWith<$R2, PatientPackageModel, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _PatientPackageModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
