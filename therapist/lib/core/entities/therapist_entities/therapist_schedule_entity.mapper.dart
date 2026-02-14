// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'therapist_schedule_entity.dart';

class TherapistScheduleEntityMapper
    extends ClassMapperBase<TherapistScheduleEntity> {
  TherapistScheduleEntityMapper._();

  static TherapistScheduleEntityMapper? _instance;
  static TherapistScheduleEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = TherapistScheduleEntityMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'TherapistScheduleEntity';

  static String _$sessionId(TherapistScheduleEntity v) => v.sessionId;
  static const Field<TherapistScheduleEntity, String> _f$sessionId = Field(
    'sessionId',
    _$sessionId,
    key: r'id',
  );
  static String _$createdAt(TherapistScheduleEntity v) => v.createdAt;
  static const Field<TherapistScheduleEntity, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static DateTime _$timestamp(TherapistScheduleEntity v) => v.timestamp;
  static const Field<TherapistScheduleEntity, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static String _$therapistId(TherapistScheduleEntity v) => v.therapistId;
  static const Field<TherapistScheduleEntity, String> _f$therapistId = Field(
    'therapistId',
    _$therapistId,
    key: r'therapist_id',
  );
  static String _$patientId(TherapistScheduleEntity v) => v.patientId;
  static const Field<TherapistScheduleEntity, String> _f$patientId = Field(
    'patientId',
    _$patientId,
    key: r'patient_id',
  );
  static String _$status(TherapistScheduleEntity v) => v.status;
  static const Field<TherapistScheduleEntity, String> _f$status = Field(
    'status',
    _$status,
  );
  static int? _$mode(TherapistScheduleEntity v) => v.mode;
  static const Field<TherapistScheduleEntity, int> _f$mode = Field(
    'mode',
    _$mode,
    opt: true,
  );
  static int? _$duration(TherapistScheduleEntity v) => v.duration;
  static const Field<TherapistScheduleEntity, int> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
  );
  static String? _$therapyName(TherapistScheduleEntity v) => v.therapyName;
  static const Field<TherapistScheduleEntity, String> _f$therapyName = Field(
    'therapyName',
    _$therapyName,
    key: r'name',
    opt: true,
  );
  static String? _$patientName(TherapistScheduleEntity v) => v.patientName;
  static const Field<TherapistScheduleEntity, String> _f$patientName = Field(
    'patientName',
    _$patientName,
    key: r'patient_name',
    opt: true,
  );
  static String? _$phoneNumber(TherapistScheduleEntity v) => v.phoneNumber;
  static const Field<TherapistScheduleEntity, String> _f$phoneNumber = Field(
    'phoneNumber',
    _$phoneNumber,
    key: r'phone',
    opt: true,
  );

  @override
  final MappableFields<TherapistScheduleEntity> fields = const {
    #sessionId: _f$sessionId,
    #createdAt: _f$createdAt,
    #timestamp: _f$timestamp,
    #therapistId: _f$therapistId,
    #patientId: _f$patientId,
    #status: _f$status,
    #mode: _f$mode,
    #duration: _f$duration,
    #therapyName: _f$therapyName,
    #patientName: _f$patientName,
    #phoneNumber: _f$phoneNumber,
  };

  static TherapistScheduleEntity _instantiate(DecodingData data) {
    return TherapistScheduleEntity(
      sessionId: data.dec(_f$sessionId),
      createdAt: data.dec(_f$createdAt),
      timestamp: data.dec(_f$timestamp),
      therapistId: data.dec(_f$therapistId),
      patientId: data.dec(_f$patientId),
      status: data.dec(_f$status),
      mode: data.dec(_f$mode),
      duration: data.dec(_f$duration),
      therapyName: data.dec(_f$therapyName),
      patientName: data.dec(_f$patientName),
      phoneNumber: data.dec(_f$phoneNumber),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TherapistScheduleEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TherapistScheduleEntity>(map);
  }

  static TherapistScheduleEntity fromJson(String json) {
    return ensureInitialized().decodeJson<TherapistScheduleEntity>(json);
  }
}

mixin TherapistScheduleEntityMappable {
  String toJson() {
    return TherapistScheduleEntityMapper.ensureInitialized()
        .encodeJson<TherapistScheduleEntity>(this as TherapistScheduleEntity);
  }

  Map<String, dynamic> toMap() {
    return TherapistScheduleEntityMapper.ensureInitialized()
        .encodeMap<TherapistScheduleEntity>(this as TherapistScheduleEntity);
  }

  TherapistScheduleEntityCopyWith<
    TherapistScheduleEntity,
    TherapistScheduleEntity,
    TherapistScheduleEntity
  >
  get copyWith =>
      _TherapistScheduleEntityCopyWithImpl<
        TherapistScheduleEntity,
        TherapistScheduleEntity
      >(this as TherapistScheduleEntity, $identity, $identity);
  @override
  String toString() {
    return TherapistScheduleEntityMapper.ensureInitialized().stringifyValue(
      this as TherapistScheduleEntity,
    );
  }

  @override
  bool operator ==(Object other) {
    return TherapistScheduleEntityMapper.ensureInitialized().equalsValue(
      this as TherapistScheduleEntity,
      other,
    );
  }

  @override
  int get hashCode {
    return TherapistScheduleEntityMapper.ensureInitialized().hashValue(
      this as TherapistScheduleEntity,
    );
  }
}

extension TherapistScheduleEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TherapistScheduleEntity, $Out> {
  TherapistScheduleEntityCopyWith<$R, TherapistScheduleEntity, $Out>
  get $asTherapistScheduleEntity => $base.as(
    (v, t, t2) => _TherapistScheduleEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TherapistScheduleEntityCopyWith<
  $R,
  $In extends TherapistScheduleEntity,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? sessionId,
    String? createdAt,
    DateTime? timestamp,
    String? therapistId,
    String? patientId,
    String? status,
    int? mode,
    int? duration,
    String? therapyName,
    String? patientName,
    String? phoneNumber,
  });
  TherapistScheduleEntityCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TherapistScheduleEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TherapistScheduleEntity, $Out>
    implements
        TherapistScheduleEntityCopyWith<$R, TherapistScheduleEntity, $Out> {
  _TherapistScheduleEntityCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TherapistScheduleEntity> $mapper =
      TherapistScheduleEntityMapper.ensureInitialized();
  @override
  $R call({
    String? sessionId,
    String? createdAt,
    DateTime? timestamp,
    String? therapistId,
    String? patientId,
    String? status,
    Object? mode = $none,
    Object? duration = $none,
    Object? therapyName = $none,
    Object? patientName = $none,
    Object? phoneNumber = $none,
  }) => $apply(
    FieldCopyWithData({
      if (sessionId != null) #sessionId: sessionId,
      if (createdAt != null) #createdAt: createdAt,
      if (timestamp != null) #timestamp: timestamp,
      if (therapistId != null) #therapistId: therapistId,
      if (patientId != null) #patientId: patientId,
      if (status != null) #status: status,
      if (mode != $none) #mode: mode,
      if (duration != $none) #duration: duration,
      if (therapyName != $none) #therapyName: therapyName,
      if (patientName != $none) #patientName: patientName,
      if (phoneNumber != $none) #phoneNumber: phoneNumber,
    }),
  );
  @override
  TherapistScheduleEntity $make(CopyWithData data) => TherapistScheduleEntity(
    sessionId: data.get(#sessionId, or: $value.sessionId),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    timestamp: data.get(#timestamp, or: $value.timestamp),
    therapistId: data.get(#therapistId, or: $value.therapistId),
    patientId: data.get(#patientId, or: $value.patientId),
    status: data.get(#status, or: $value.status),
    mode: data.get(#mode, or: $value.mode),
    duration: data.get(#duration, or: $value.duration),
    therapyName: data.get(#therapyName, or: $value.therapyName),
    patientName: data.get(#patientName, or: $value.patientName),
    phoneNumber: data.get(#phoneNumber, or: $value.phoneNumber),
  );

  @override
  TherapistScheduleEntityCopyWith<$R2, TherapistScheduleEntity, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TherapistScheduleEntityCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

