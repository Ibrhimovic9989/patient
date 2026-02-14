// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'daily_activity_response_model.dart';

class DailyActivityResponseModelMapper
    extends ClassMapperBase<DailyActivityResponseModel> {
  DailyActivityResponseModelMapper._();

  static DailyActivityResponseModelMapper? _instance;
  static DailyActivityResponseModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = DailyActivityResponseModelMapper._(),
      );
      DailyActivityModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DailyActivityResponseModel';

  static String _$id(DailyActivityResponseModel v) => v.id;
  static const Field<DailyActivityResponseModel, String> _f$id = Field(
    'id',
    _$id,
  );
  static String _$createdAt(DailyActivityResponseModel v) => v.createdAt;
  static const Field<DailyActivityResponseModel, String> _f$createdAt = Field(
    'createdAt',
    _$createdAt,
    key: r'created_at',
  );
  static String _$activityName(DailyActivityResponseModel v) => v.activityName;
  static const Field<DailyActivityResponseModel, String> _f$activityName =
      Field('activityName', _$activityName, key: r'activity_name');
  static List<DailyActivityModel> _$activityList(
    DailyActivityResponseModel v,
  ) => v.activityList;
  static const Field<DailyActivityResponseModel, List<DailyActivityModel>>
  _f$activityList = Field(
    'activityList',
    _$activityList,
    key: r'activity_list',
  );
  static bool _$isActive(DailyActivityResponseModel v) => v.isActive;
  static const Field<DailyActivityResponseModel, bool> _f$isActive = Field(
    'isActive',
    _$isActive,
    key: r'is_active',
  );
  static String _$patientId(DailyActivityResponseModel v) => v.patientId;
  static const Field<DailyActivityResponseModel, String> _f$patientId = Field(
    'patientId',
    _$patientId,
    key: r'patient_id',
  );
  static String _$therapistId(DailyActivityResponseModel v) => v.therapistId;
  static const Field<DailyActivityResponseModel, String> _f$therapistId = Field(
    'therapistId',
    _$therapistId,
    key: r'therapist_id',
  );
  static String _$startTime(DailyActivityResponseModel v) => v.startTime;
  static const Field<DailyActivityResponseModel, String> _f$startTime = Field(
    'startTime',
    _$startTime,
    key: r'start_time',
  );
  static String _$endTime(DailyActivityResponseModel v) => v.endTime;
  static const Field<DailyActivityResponseModel, String> _f$endTime = Field(
    'endTime',
    _$endTime,
    key: r'end_time',
  );
  static List<String> _$daysOfWeek(DailyActivityResponseModel v) =>
      v.daysOfWeek;
  static const Field<DailyActivityResponseModel, List<String>> _f$daysOfWeek =
      Field('daysOfWeek', _$daysOfWeek, key: r'days_of_week');
  static Map<String, String>? _$instructions(DailyActivityResponseModel v) =>
      v.instructions;
  static const Field<DailyActivityResponseModel, Map<String, String>>
  _f$instructions = Field('instructions', _$instructions, opt: true);
  static Map<String, dynamic>? _$reminderSettings(
    DailyActivityResponseModel v,
  ) => v.reminderSettings;
  static const Field<DailyActivityResponseModel, Map<String, dynamic>>
  _f$reminderSettings = Field(
    'reminderSettings',
    _$reminderSettings,
    key: r'reminder_settings',
    opt: true,
  );

  @override
  final MappableFields<DailyActivityResponseModel> fields = const {
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

  static DailyActivityResponseModel _instantiate(DecodingData data) {
    return DailyActivityResponseModel(
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

  static DailyActivityResponseModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyActivityResponseModel>(map);
  }

  static DailyActivityResponseModel fromJson(String json) {
    return ensureInitialized().decodeJson<DailyActivityResponseModel>(json);
  }
}

mixin DailyActivityResponseModelMappable {
  String toJson() {
    return DailyActivityResponseModelMapper.ensureInitialized()
        .encodeJson<DailyActivityResponseModel>(
          this as DailyActivityResponseModel,
        );
  }

  Map<String, dynamic> toMap() {
    return DailyActivityResponseModelMapper.ensureInitialized()
        .encodeMap<DailyActivityResponseModel>(
          this as DailyActivityResponseModel,
        );
  }

  DailyActivityResponseModelCopyWith<
    DailyActivityResponseModel,
    DailyActivityResponseModel,
    DailyActivityResponseModel
  >
  get copyWith =>
      _DailyActivityResponseModelCopyWithImpl<
        DailyActivityResponseModel,
        DailyActivityResponseModel
      >(this as DailyActivityResponseModel, $identity, $identity);
  @override
  String toString() {
    return DailyActivityResponseModelMapper.ensureInitialized().stringifyValue(
      this as DailyActivityResponseModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyActivityResponseModelMapper.ensureInitialized().equalsValue(
      this as DailyActivityResponseModel,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyActivityResponseModelMapper.ensureInitialized().hashValue(
      this as DailyActivityResponseModel,
    );
  }
}

extension DailyActivityResponseModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyActivityResponseModel, $Out> {
  DailyActivityResponseModelCopyWith<$R, DailyActivityResponseModel, $Out>
  get $asDailyActivityResponseModel => $base.as(
    (v, t, t2) => _DailyActivityResponseModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DailyActivityResponseModelCopyWith<
  $R,
  $In extends DailyActivityResponseModel,
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
  DailyActivityResponseModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DailyActivityResponseModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyActivityResponseModel, $Out>
    implements
        DailyActivityResponseModelCopyWith<
          $R,
          DailyActivityResponseModel,
          $Out
        > {
  _DailyActivityResponseModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyActivityResponseModel> $mapper =
      DailyActivityResponseModelMapper.ensureInitialized();
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
  DailyActivityResponseModel $make(CopyWithData data) =>
      DailyActivityResponseModel(
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
        reminderSettings: data.get(
          #reminderSettings,
          or: $value.reminderSettings,
        ),
      );

  @override
  DailyActivityResponseModelCopyWith<$R2, DailyActivityResponseModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _DailyActivityResponseModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

