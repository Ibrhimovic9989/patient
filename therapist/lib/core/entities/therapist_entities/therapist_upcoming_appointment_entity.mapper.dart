// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'therapist_upcoming_appointment_entity.dart';

class TherapistUpcomingAppointmentEntityMapper
    extends ClassMapperBase<TherapistUpcomingAppointmentEntity> {
  TherapistUpcomingAppointmentEntityMapper._();

  static TherapistUpcomingAppointmentEntityMapper? _instance;
  static TherapistUpcomingAppointmentEntityMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = TherapistUpcomingAppointmentEntityMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'TherapistUpcomingAppointmentEntity';

  static String _$sessionId(TherapistUpcomingAppointmentEntity v) =>
      v.sessionId;
  static const Field<TherapistUpcomingAppointmentEntity, String> _f$sessionId =
      Field('sessionId', _$sessionId, key: r'id');
  static String _$createdAt(TherapistUpcomingAppointmentEntity v) =>
      v.createdAt;
  static const Field<TherapistUpcomingAppointmentEntity, String> _f$createdAt =
      Field('createdAt', _$createdAt, key: r'created_at');
  static DateTime _$timestamp(TherapistUpcomingAppointmentEntity v) =>
      v.timestamp;
  static const Field<TherapistUpcomingAppointmentEntity, DateTime>
  _f$timestamp = Field('timestamp', _$timestamp);
  static String _$therapistId(TherapistUpcomingAppointmentEntity v) =>
      v.therapistId;
  static const Field<TherapistUpcomingAppointmentEntity, String>
  _f$therapistId = Field('therapistId', _$therapistId, key: r'therapist_id');
  static String _$patientId(TherapistUpcomingAppointmentEntity v) =>
      v.patientId;
  static const Field<TherapistUpcomingAppointmentEntity, String> _f$patientId =
      Field('patientId', _$patientId, key: r'patient_id');
  static String _$status(TherapistUpcomingAppointmentEntity v) => v.status;
  static const Field<TherapistUpcomingAppointmentEntity, String> _f$status =
      Field('status', _$status);
  static int? _$mode(TherapistUpcomingAppointmentEntity v) => v.mode;
  static const Field<TherapistUpcomingAppointmentEntity, int> _f$mode = Field(
    'mode',
    _$mode,
    opt: true,
  );
  static int? _$duration(TherapistUpcomingAppointmentEntity v) => v.duration;
  static const Field<TherapistUpcomingAppointmentEntity, int> _f$duration =
      Field('duration', _$duration, opt: true);
  static String? _$therapyName(TherapistUpcomingAppointmentEntity v) =>
      v.therapyName;
  static const Field<TherapistUpcomingAppointmentEntity, String>
  _f$therapyName = Field('therapyName', _$therapyName, key: r'name', opt: true);

  @override
  final MappableFields<TherapistUpcomingAppointmentEntity> fields = const {
    #sessionId: _f$sessionId,
    #createdAt: _f$createdAt,
    #timestamp: _f$timestamp,
    #therapistId: _f$therapistId,
    #patientId: _f$patientId,
    #status: _f$status,
    #mode: _f$mode,
    #duration: _f$duration,
    #therapyName: _f$therapyName,
  };

  static TherapistUpcomingAppointmentEntity _instantiate(DecodingData data) {
    return TherapistUpcomingAppointmentEntity(
      sessionId: data.dec(_f$sessionId),
      createdAt: data.dec(_f$createdAt),
      timestamp: data.dec(_f$timestamp),
      therapistId: data.dec(_f$therapistId),
      patientId: data.dec(_f$patientId),
      status: data.dec(_f$status),
      mode: data.dec(_f$mode),
      duration: data.dec(_f$duration),
      therapyName: data.dec(_f$therapyName),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TherapistUpcomingAppointmentEntity fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TherapistUpcomingAppointmentEntity>(
      map,
    );
  }

  static TherapistUpcomingAppointmentEntity fromJson(String json) {
    return ensureInitialized().decodeJson<TherapistUpcomingAppointmentEntity>(
      json,
    );
  }
}

mixin TherapistUpcomingAppointmentEntityMappable {
  String toJson() {
    return TherapistUpcomingAppointmentEntityMapper.ensureInitialized()
        .encodeJson<TherapistUpcomingAppointmentEntity>(
          this as TherapistUpcomingAppointmentEntity,
        );
  }

  Map<String, dynamic> toMap() {
    return TherapistUpcomingAppointmentEntityMapper.ensureInitialized()
        .encodeMap<TherapistUpcomingAppointmentEntity>(
          this as TherapistUpcomingAppointmentEntity,
        );
  }

  TherapistUpcomingAppointmentEntityCopyWith<
    TherapistUpcomingAppointmentEntity,
    TherapistUpcomingAppointmentEntity,
    TherapistUpcomingAppointmentEntity
  >
  get copyWith =>
      _TherapistUpcomingAppointmentEntityCopyWithImpl<
        TherapistUpcomingAppointmentEntity,
        TherapistUpcomingAppointmentEntity
      >(this as TherapistUpcomingAppointmentEntity, $identity, $identity);
  @override
  String toString() {
    return TherapistUpcomingAppointmentEntityMapper.ensureInitialized()
        .stringifyValue(this as TherapistUpcomingAppointmentEntity);
  }

  @override
  bool operator ==(Object other) {
    return TherapistUpcomingAppointmentEntityMapper.ensureInitialized()
        .equalsValue(this as TherapistUpcomingAppointmentEntity, other);
  }

  @override
  int get hashCode {
    return TherapistUpcomingAppointmentEntityMapper.ensureInitialized()
        .hashValue(this as TherapistUpcomingAppointmentEntity);
  }
}

extension TherapistUpcomingAppointmentEntityValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TherapistUpcomingAppointmentEntity, $Out> {
  TherapistUpcomingAppointmentEntityCopyWith<
    $R,
    TherapistUpcomingAppointmentEntity,
    $Out
  >
  get $asTherapistUpcomingAppointmentEntity => $base.as(
    (v, t, t2) =>
        _TherapistUpcomingAppointmentEntityCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TherapistUpcomingAppointmentEntityCopyWith<
  $R,
  $In extends TherapistUpcomingAppointmentEntity,
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
  });
  TherapistUpcomingAppointmentEntityCopyWith<$R2, $In, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TherapistUpcomingAppointmentEntityCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TherapistUpcomingAppointmentEntity, $Out>
    implements
        TherapistUpcomingAppointmentEntityCopyWith<
          $R,
          TherapistUpcomingAppointmentEntity,
          $Out
        > {
  _TherapistUpcomingAppointmentEntityCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<TherapistUpcomingAppointmentEntity> $mapper =
      TherapistUpcomingAppointmentEntityMapper.ensureInitialized();
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
    }),
  );
  @override
  TherapistUpcomingAppointmentEntity $make(CopyWithData data) =>
      TherapistUpcomingAppointmentEntity(
        sessionId: data.get(#sessionId, or: $value.sessionId),
        createdAt: data.get(#createdAt, or: $value.createdAt),
        timestamp: data.get(#timestamp, or: $value.timestamp),
        therapistId: data.get(#therapistId, or: $value.therapistId),
        patientId: data.get(#patientId, or: $value.patientId),
        status: data.get(#status, or: $value.status),
        mode: data.get(#mode, or: $value.mode),
        duration: data.get(#duration, or: $value.duration),
        therapyName: data.get(#therapyName, or: $value.therapyName),
      );

  @override
  TherapistUpcomingAppointmentEntityCopyWith<
    $R2,
    TherapistUpcomingAppointmentEntity,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TherapistUpcomingAppointmentEntityCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

