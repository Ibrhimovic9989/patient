// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'therapist_upcoming_appointment_model.dart';

class TherapistUpcomingAppointmentModelMapper
    extends ClassMapperBase<TherapistUpcomingAppointmentModel> {
  TherapistUpcomingAppointmentModelMapper._();

  static TherapistUpcomingAppointmentModelMapper? _instance;
  static TherapistUpcomingAppointmentModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = TherapistUpcomingAppointmentModelMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'TherapistUpcomingAppointmentModel';

  static String _$sessionId(TherapistUpcomingAppointmentModel v) => v.sessionId;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$sessionId =
      Field('sessionId', _$sessionId);
  static String _$patientId(TherapistUpcomingAppointmentModel v) => v.patientId;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$patientId =
      Field('patientId', _$patientId);
  static String _$patientName(TherapistUpcomingAppointmentModel v) =>
      v.patientName;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$patientName =
      Field('patientName', _$patientName);
  static String _$phoneNo(TherapistUpcomingAppointmentModel v) => v.phoneNo;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$phoneNo =
      Field('phoneNo', _$phoneNo);
  static String _$therapyName(TherapistUpcomingAppointmentModel v) =>
      v.therapyName;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$therapyName =
      Field('therapyName', _$therapyName);
  static DateTime _$timestamp(TherapistUpcomingAppointmentModel v) =>
      v.timestamp;
  static const Field<TherapistUpcomingAppointmentModel, DateTime> _f$timestamp =
      Field('timestamp', _$timestamp);
  static String? _$mode(TherapistUpcomingAppointmentModel v) => v.mode;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$mode = Field(
    'mode',
    _$mode,
    opt: true,
  );
  static int? _$duration(TherapistUpcomingAppointmentModel v) => v.duration;
  static const Field<TherapistUpcomingAppointmentModel, int> _f$duration =
      Field('duration', _$duration, opt: true);
  static String? _$status(TherapistUpcomingAppointmentModel v) => v.status;
  static const Field<TherapistUpcomingAppointmentModel, String> _f$status =
      Field('status', _$status, opt: true);

  @override
  final MappableFields<TherapistUpcomingAppointmentModel> fields = const {
    #sessionId: _f$sessionId,
    #patientId: _f$patientId,
    #patientName: _f$patientName,
    #phoneNo: _f$phoneNo,
    #therapyName: _f$therapyName,
    #timestamp: _f$timestamp,
    #mode: _f$mode,
    #duration: _f$duration,
    #status: _f$status,
  };

  static TherapistUpcomingAppointmentModel _instantiate(DecodingData data) {
    return TherapistUpcomingAppointmentModel(
      sessionId: data.dec(_f$sessionId),
      patientId: data.dec(_f$patientId),
      patientName: data.dec(_f$patientName),
      phoneNo: data.dec(_f$phoneNo),
      therapyName: data.dec(_f$therapyName),
      timestamp: data.dec(_f$timestamp),
      mode: data.dec(_f$mode),
      duration: data.dec(_f$duration),
      status: data.dec(_f$status),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TherapistUpcomingAppointmentModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TherapistUpcomingAppointmentModel>(
      map,
    );
  }

  static TherapistUpcomingAppointmentModel fromJson(String json) {
    return ensureInitialized().decodeJson<TherapistUpcomingAppointmentModel>(
      json,
    );
  }
}

mixin TherapistUpcomingAppointmentModelMappable {
  String toJson() {
    return TherapistUpcomingAppointmentModelMapper.ensureInitialized()
        .encodeJson<TherapistUpcomingAppointmentModel>(
          this as TherapistUpcomingAppointmentModel,
        );
  }

  Map<String, dynamic> toMap() {
    return TherapistUpcomingAppointmentModelMapper.ensureInitialized()
        .encodeMap<TherapistUpcomingAppointmentModel>(
          this as TherapistUpcomingAppointmentModel,
        );
  }

  TherapistUpcomingAppointmentModelCopyWith<
    TherapistUpcomingAppointmentModel,
    TherapistUpcomingAppointmentModel,
    TherapistUpcomingAppointmentModel
  >
  get copyWith =>
      _TherapistUpcomingAppointmentModelCopyWithImpl<
        TherapistUpcomingAppointmentModel,
        TherapistUpcomingAppointmentModel
      >(this as TherapistUpcomingAppointmentModel, $identity, $identity);
  @override
  String toString() {
    return TherapistUpcomingAppointmentModelMapper.ensureInitialized()
        .stringifyValue(this as TherapistUpcomingAppointmentModel);
  }

  @override
  bool operator ==(Object other) {
    return TherapistUpcomingAppointmentModelMapper.ensureInitialized()
        .equalsValue(this as TherapistUpcomingAppointmentModel, other);
  }

  @override
  int get hashCode {
    return TherapistUpcomingAppointmentModelMapper.ensureInitialized()
        .hashValue(this as TherapistUpcomingAppointmentModel);
  }
}

extension TherapistUpcomingAppointmentModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TherapistUpcomingAppointmentModel, $Out> {
  TherapistUpcomingAppointmentModelCopyWith<
    $R,
    TherapistUpcomingAppointmentModel,
    $Out
  >
  get $asTherapistUpcomingAppointmentModel => $base.as(
    (v, t, t2) =>
        _TherapistUpcomingAppointmentModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TherapistUpcomingAppointmentModelCopyWith<
  $R,
  $In extends TherapistUpcomingAppointmentModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? sessionId,
    String? patientId,
    String? patientName,
    String? phoneNo,
    String? therapyName,
    DateTime? timestamp,
    String? mode,
    int? duration,
    String? status,
  });
  TherapistUpcomingAppointmentModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TherapistUpcomingAppointmentModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TherapistUpcomingAppointmentModel, $Out>
    implements
        TherapistUpcomingAppointmentModelCopyWith<
          $R,
          TherapistUpcomingAppointmentModel,
          $Out
        > {
  _TherapistUpcomingAppointmentModelCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<TherapistUpcomingAppointmentModel> $mapper =
      TherapistUpcomingAppointmentModelMapper.ensureInitialized();
  @override
  $R call({
    String? sessionId,
    String? patientId,
    String? patientName,
    String? phoneNo,
    String? therapyName,
    DateTime? timestamp,
    Object? mode = $none,
    Object? duration = $none,
    Object? status = $none,
  }) => $apply(
    FieldCopyWithData({
      if (sessionId != null) #sessionId: sessionId,
      if (patientId != null) #patientId: patientId,
      if (patientName != null) #patientName: patientName,
      if (phoneNo != null) #phoneNo: phoneNo,
      if (therapyName != null) #therapyName: therapyName,
      if (timestamp != null) #timestamp: timestamp,
      if (mode != $none) #mode: mode,
      if (duration != $none) #duration: duration,
      if (status != $none) #status: status,
    }),
  );
  @override
  TherapistUpcomingAppointmentModel $make(CopyWithData data) =>
      TherapistUpcomingAppointmentModel(
        sessionId: data.get(#sessionId, or: $value.sessionId),
        patientId: data.get(#patientId, or: $value.patientId),
        patientName: data.get(#patientName, or: $value.patientName),
        phoneNo: data.get(#phoneNo, or: $value.phoneNo),
        therapyName: data.get(#therapyName, or: $value.therapyName),
        timestamp: data.get(#timestamp, or: $value.timestamp),
        mode: data.get(#mode, or: $value.mode),
        duration: data.get(#duration, or: $value.duration),
        status: data.get(#status, or: $value.status),
      );

  @override
  TherapistUpcomingAppointmentModelCopyWith<
    $R2,
    TherapistUpcomingAppointmentModel,
    $Out2
  >
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TherapistUpcomingAppointmentModelCopyWithImpl<$R2, $Out2>(
        $value,
        $cast,
        t,
      );
}

