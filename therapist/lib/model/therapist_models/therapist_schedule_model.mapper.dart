// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'therapist_schedule_model.dart';

class TherapistScheduleModelMapper
    extends ClassMapperBase<TherapistScheduleModel> {
  TherapistScheduleModelMapper._();

  static TherapistScheduleModelMapper? _instance;
  static TherapistScheduleModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TherapistScheduleModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TherapistScheduleModel';

  static String _$sessionId(TherapistScheduleModel v) => v.sessionId;
  static const Field<TherapistScheduleModel, String> _f$sessionId = Field(
    'sessionId',
    _$sessionId,
  );
  static String _$patientId(TherapistScheduleModel v) => v.patientId;
  static const Field<TherapistScheduleModel, String> _f$patientId = Field(
    'patientId',
    _$patientId,
  );
  static String _$patientName(TherapistScheduleModel v) => v.patientName;
  static const Field<TherapistScheduleModel, String> _f$patientName = Field(
    'patientName',
    _$patientName,
  );
  static String _$phoneNo(TherapistScheduleModel v) => v.phoneNo;
  static const Field<TherapistScheduleModel, String> _f$phoneNo = Field(
    'phoneNo',
    _$phoneNo,
  );
  static String _$therapyName(TherapistScheduleModel v) => v.therapyName;
  static const Field<TherapistScheduleModel, String> _f$therapyName = Field(
    'therapyName',
    _$therapyName,
  );
  static DateTime _$timestamp(TherapistScheduleModel v) => v.timestamp;
  static const Field<TherapistScheduleModel, DateTime> _f$timestamp = Field(
    'timestamp',
    _$timestamp,
  );
  static String? _$mode(TherapistScheduleModel v) => v.mode;
  static const Field<TherapistScheduleModel, String> _f$mode = Field(
    'mode',
    _$mode,
    opt: true,
  );
  static int? _$duration(TherapistScheduleModel v) => v.duration;
  static const Field<TherapistScheduleModel, int> _f$duration = Field(
    'duration',
    _$duration,
    opt: true,
  );
  static String? _$status(TherapistScheduleModel v) => v.status;
  static const Field<TherapistScheduleModel, String> _f$status = Field(
    'status',
    _$status,
    opt: true,
  );

  @override
  final MappableFields<TherapistScheduleModel> fields = const {
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

  static TherapistScheduleModel _instantiate(DecodingData data) {
    return TherapistScheduleModel(
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

  static TherapistScheduleModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TherapistScheduleModel>(map);
  }

  static TherapistScheduleModel fromJson(String json) {
    return ensureInitialized().decodeJson<TherapistScheduleModel>(json);
  }
}

mixin TherapistScheduleModelMappable {
  String toJson() {
    return TherapistScheduleModelMapper.ensureInitialized()
        .encodeJson<TherapistScheduleModel>(this as TherapistScheduleModel);
  }

  Map<String, dynamic> toMap() {
    return TherapistScheduleModelMapper.ensureInitialized()
        .encodeMap<TherapistScheduleModel>(this as TherapistScheduleModel);
  }

  TherapistScheduleModelCopyWith<
    TherapistScheduleModel,
    TherapistScheduleModel,
    TherapistScheduleModel
  >
  get copyWith =>
      _TherapistScheduleModelCopyWithImpl<
        TherapistScheduleModel,
        TherapistScheduleModel
      >(this as TherapistScheduleModel, $identity, $identity);
  @override
  String toString() {
    return TherapistScheduleModelMapper.ensureInitialized().stringifyValue(
      this as TherapistScheduleModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TherapistScheduleModelMapper.ensureInitialized().equalsValue(
      this as TherapistScheduleModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TherapistScheduleModelMapper.ensureInitialized().hashValue(
      this as TherapistScheduleModel,
    );
  }
}

extension TherapistScheduleModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TherapistScheduleModel, $Out> {
  TherapistScheduleModelCopyWith<$R, TherapistScheduleModel, $Out>
  get $asTherapistScheduleModel => $base.as(
    (v, t, t2) => _TherapistScheduleModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TherapistScheduleModelCopyWith<
  $R,
  $In extends TherapistScheduleModel,
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
  TherapistScheduleModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TherapistScheduleModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TherapistScheduleModel, $Out>
    implements
        TherapistScheduleModelCopyWith<$R, TherapistScheduleModel, $Out> {
  _TherapistScheduleModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TherapistScheduleModel> $mapper =
      TherapistScheduleModelMapper.ensureInitialized();
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
  TherapistScheduleModel $make(CopyWithData data) => TherapistScheduleModel(
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
  TherapistScheduleModelCopyWith<$R2, TherapistScheduleModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TherapistScheduleModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

