// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'daily_activity_response.dart';

class DailyActivityResponseMapper
    extends ClassMapperBase<DailyActivityResponse> {
  DailyActivityResponseMapper._();

  static DailyActivityResponseMapper? _instance;
  static DailyActivityResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyActivityResponseMapper._());
      DailyActivityModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DailyActivityResponse';

  static String _$id(DailyActivityResponse v) => v.id;
  static const Field<DailyActivityResponse, String> _f$id = Field('id', _$id);
  static String _$createdAt(DailyActivityResponse v) => v.createdAt;
  static const Field<DailyActivityResponse, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$activityName(DailyActivityResponse v) => v.activityName;
  static const Field<DailyActivityResponse, String> _f$activityName = Field(
    'activityName',
    _$activityName,
    key: r'activity_name',
  );
  static List<DailyActivityModel> _$activityList(DailyActivityResponse v) =>
      v.activityList;
  static const Field<DailyActivityResponse, List<DailyActivityModel>>
  _f$activityList = Field(
    'activityList',
    _$activityList,
    key: r'activity_list',
  );
  static bool _$isActive(DailyActivityResponse v) => v.isActive;
  static const Field<DailyActivityResponse, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    key: r'is_active',
  );
  static String _$patientId(DailyActivityResponse v) => v.patientId;
  static const Field<DailyActivityResponse, String> _f$patientId = Field(
    'patientId',
    _$patientId,
    key: r'patient_id',
  );
  static String _$therapistId(DailyActivityResponse v) => v.therapistId;
  static const Field<DailyActivityResponse, String> _f$therapistId = Field(
    'therapistId',
    _$therapistId,
    key: r'therapist_id',
  );
  static String _$startTime(DailyActivityResponse v) => v.startTime;
  static const Field<DailyActivityResponse, String> _f$startTime = Field(
    'startTime',
    _$startTime,
    key: r'start_time',
  );
  static String _$endTime(DailyActivityResponse v) => v.endTime;
  static const Field<DailyActivityResponse, String> _f$endTime = Field(
    'endTime',
    _$endTime,
    key: r'end_time',
  );
  static List<String> _$daysOfWeek(DailyActivityResponse v) => v.daysOfWeek;
  static const Field<DailyActivityResponse, List<String>> _f$daysOfWeek = Field(
    'daysOfWeek',
    _$daysOfWeek,
    key: r'days_of_week',
  );
  static Map<String, String>? _$instructions(DailyActivityResponse v) =>
      v.instructions;
  static const Field<DailyActivityResponse, Map<String, String>>
  _f$instructions = Field('instructions', _$instructions, opt: true);
  static Map<String, dynamic>? _$reminderSettings(DailyActivityResponse v) =>
      v.reminderSettings;
  static const Field<DailyActivityResponse, Map<String, dynamic>>
  _f$reminderSettings = Field(
    'reminderSettings',
    _$reminderSettings,
    key: r'reminder_settings',
    opt: true,
  );

  @override
  final MappableFields<DailyActivityResponse> fields = const {
    #id: _f$id,
    #createdAt: _f$createdAt,
    #activityName: _f$activityName,
    #activityList: _f$activityList,
    #isActive: _f$isActive,
    #patientId: _f$patientId,
    #therapistId: _f$therapistId,
    #startTime: _f$startTime,
    #endTime: _f$endTime,
    #daysOfWeek: _f$daysOfWeek,
    #instructions: _f$instructions,
    #reminderSettings: _f$reminderSettings,
  };

  static DailyActivityResponse _instantiate(DecodingData data) {
    return DailyActivityResponse(
      id: data.dec(_f$id),
      createdAt: data.dec(_f$createdAt),
      activityName: data.dec(_f$activityName),
      activityList: data.dec(_f$activityList),
      isActive: data.dec(_f$isActive),
      patientId: data.dec(_f$patientId),
      therapistId: data.dec(_f$therapistId),
      startTime: data.dec(_f$startTime),
      endTime: data.dec(_f$endTime),
      daysOfWeek: data.dec(_f$daysOfWeek),
      instructions: data.dec(_f$instructions),
      reminderSettings: data.dec(_f$reminderSettings),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DailyActivityResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyActivityResponse>(map);
  }

  static DailyActivityResponse fromJson(String json) {
    return ensureInitialized().decodeJson<DailyActivityResponse>(json);
  }
}

mixin DailyActivityResponseMappable {
  String toJson() {
    return DailyActivityResponseMapper.ensureInitialized()
        .encodeJson<DailyActivityResponse>(this as DailyActivityResponse);
  }

  Map<String, dynamic> toMap() {
    return DailyActivityResponseMapper.ensureInitialized()
        .encodeMap<DailyActivityResponse>(this as DailyActivityResponse);
  }

  DailyActivityResponseCopyWith<
    DailyActivityResponse,
    DailyActivityResponse,
    DailyActivityResponse
  >
  get copyWith =>
      _DailyActivityResponseCopyWithImpl<
        DailyActivityResponse,
        DailyActivityResponse
      >(this as DailyActivityResponse, $identity, $identity);
  @override
  String toString() {
    return DailyActivityResponseMapper.ensureInitialized().stringifyValue(
      this as DailyActivityResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyActivityResponseMapper.ensureInitialized().equalsValue(
      this as DailyActivityResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyActivityResponseMapper.ensureInitialized().hashValue(
      this as DailyActivityResponse,
    );
  }
}

extension DailyActivityResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyActivityResponse, $Out> {
  DailyActivityResponseCopyWith<$R, DailyActivityResponse, $Out>
  get $asDailyActivityResponse => $base.as(
    (v, t, t2) => _DailyActivityResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DailyActivityResponseCopyWith<
  $R,
  $In extends DailyActivityResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    DailyActivityModel,
    DailyActivityModelCopyWith<$R, DailyActivityModel, DailyActivityModel>
  >
  get activityList;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get daysOfWeek;
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get instructions;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get reminderSettings;
  $R call({
    String? id,
    String? createdAt,
    String? activityName,
    List<DailyActivityModel>? activityList,
    bool? isActive,
    String? patientId,
    String? therapistId,
    String? startTime,
    String? endTime,
    List<String>? daysOfWeek,
    Map<String, String>? instructions,
    Map<String, dynamic>? reminderSettings,
  });
  DailyActivityResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DailyActivityResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyActivityResponse, $Out>
    implements DailyActivityResponseCopyWith<$R, DailyActivityResponse, $Out> {
  _DailyActivityResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyActivityResponse> $mapper =
      DailyActivityResponseMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    DailyActivityModel,
    DailyActivityModelCopyWith<$R, DailyActivityModel, DailyActivityModel>
  >
  get activityList => ListCopyWith(
    $value.activityList,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(activityList: v),
  );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get daysOfWeek =>
      ListCopyWith(
        $value.daysOfWeek,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(daysOfWeek: v),
      );
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get instructions => $value.instructions != null
      ? MapCopyWith(
          $value.instructions!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(instructions: v),
        )
      : null;
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get reminderSettings => $value.reminderSettings != null
      ? MapCopyWith(
          $value.reminderSettings!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(reminderSettings: v),
        )
      : null;
  @override
  $R call({
    String? id,
    String? createdAt,
    String? activityName,
    List<DailyActivityModel>? activityList,
    bool? isActive,
    String? patientId,
    String? therapistId,
    String? startTime,
    String? endTime,
    List<String>? daysOfWeek,
    Object? instructions = $none,
    Object? reminderSettings = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (createdAt != null) #createdAt: createdAt,
      if (activityName != null) #activityName: activityName,
      if (activityList != null) #activityList: activityList,
      if (isActive != null) #isActive: isActive,
      if (patientId != null) #patientId: patientId,
      if (therapistId != null) #therapistId: therapistId,
      if (startTime != null) #startTime: startTime,
      if (endTime != null) #endTime: endTime,
      if (daysOfWeek != null) #daysOfWeek: daysOfWeek,
      if (instructions != $none) #instructions: instructions,
      if (reminderSettings != $none) #reminderSettings: reminderSettings,
    }),
  );
  @override
  DailyActivityResponse $make(CopyWithData data) => DailyActivityResponse(
    id: data.get(#id, or: $value.id),
    createdAt: data.get(#createdAt, or: $value.createdAt),
    activityName: data.get(#activityName, or: $value.activityName),
    activityList: data.get(#activityList, or: $value.activityList),
    isActive: data.get(#isActive, or: $value.isActive),
    patientId: data.get(#patientId, or: $value.patientId),
    therapistId: data.get(#therapistId, or: $value.therapistId),
    startTime: data.get(#startTime, or: $value.startTime),
    endTime: data.get(#endTime, or: $value.endTime),
    daysOfWeek: data.get(#daysOfWeek, or: $value.daysOfWeek),
    instructions: data.get(#instructions, or: $value.instructions),
    reminderSettings: data.get(#reminderSettings, or: $value.reminderSettings),
  );

  @override
  DailyActivityResponseCopyWith<$R2, DailyActivityResponse, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DailyActivityResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

