// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'daily_activity_model.dart';

class DailyActivityModelMapper extends ClassMapperBase<DailyActivityModel> {
  DailyActivityModelMapper._();

  static DailyActivityModelMapper? _instance;
  static DailyActivityModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyActivityModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DailyActivityModel';

  static String _$id(DailyActivityModel v) => v.id;
  static const Field<DailyActivityModel, String> _f$id = Field('id', _$id);
  static String _$activity(DailyActivityModel v) => v.activity;
  static const Field<DailyActivityModel, String> _f$activity = Field(
    'activity',
    _$activity,
  );
  static bool _$isCompleted(DailyActivityModel v) => v.isCompleted;
  static const Field<DailyActivityModel, bool> _f$isCompleted = Field(
    'isCompleted',
    _$isCompleted,
    key: r'is_completed',
  );
  static String? _$instructions(DailyActivityModel v) => v.instructions;
  static const Field<DailyActivityModel, String> _f$instructions = Field(
    'instructions',
    _$instructions,
    opt: true,
  );

  @override
  final MappableFields<DailyActivityModel> fields = const {
    #id: _f$id,
    #activity: _f$activity,
    #isCompleted: _f$isCompleted,
    #instructions: _f$instructions,
  };

  static DailyActivityModel _instantiate(DecodingData data) {
    return DailyActivityModel(
      id: data.dec(_f$id),
      activity: data.dec(_f$activity),
      isCompleted: data.dec(_f$isCompleted),
      instructions: data.dec(_f$instructions),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DailyActivityModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyActivityModel>(map);
  }

  static DailyActivityModel fromJson(String json) {
    return ensureInitialized().decodeJson<DailyActivityModel>(json);
  }
}

mixin DailyActivityModelMappable {
  String toJson() {
    return DailyActivityModelMapper.ensureInitialized()
        .encodeJson<DailyActivityModel>(this as DailyActivityModel);
  }

  Map<String, dynamic> toMap() {
    return DailyActivityModelMapper.ensureInitialized()
        .encodeMap<DailyActivityModel>(this as DailyActivityModel);
  }

  DailyActivityModelCopyWith<
    DailyActivityModel,
    DailyActivityModel,
    DailyActivityModel
  >
  get copyWith =>
      _DailyActivityModelCopyWithImpl<DailyActivityModel, DailyActivityModel>(
        this as DailyActivityModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DailyActivityModelMapper.ensureInitialized().stringifyValue(
      this as DailyActivityModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyActivityModelMapper.ensureInitialized().equalsValue(
      this as DailyActivityModel,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyActivityModelMapper.ensureInitialized().hashValue(
      this as DailyActivityModel,
    );
  }
}

extension DailyActivityModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyActivityModel, $Out> {
  DailyActivityModelCopyWith<$R, DailyActivityModel, $Out>
  get $asDailyActivityModel => $base.as(
    (v, t, t2) => _DailyActivityModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class DailyActivityModelCopyWith<
  $R,
  $In extends DailyActivityModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? activity,
    bool? isCompleted,
    String? instructions,
  });
  DailyActivityModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DailyActivityModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyActivityModel, $Out>
    implements DailyActivityModelCopyWith<$R, DailyActivityModel, $Out> {
  _DailyActivityModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyActivityModel> $mapper =
      DailyActivityModelMapper.ensureInitialized();
  @override
  $R call({
    String? id,
    String? activity,
    bool? isCompleted,
    Object? instructions = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != null) #id: id,
      if (activity != null) #activity: activity,
      if (isCompleted != null) #isCompleted: isCompleted,
      if (instructions != $none) #instructions: instructions,
    }),
  );
  @override
  DailyActivityModel $make(CopyWithData data) => DailyActivityModel(
    id: data.get(#id, or: $value.id),
    activity: data.get(#activity, or: $value.activity),
    isCompleted: data.get(#isCompleted, or: $value.isCompleted),
    instructions: data.get(#instructions, or: $value.instructions),
  );

  @override
  DailyActivityModelCopyWith<$R2, DailyActivityModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DailyActivityModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

