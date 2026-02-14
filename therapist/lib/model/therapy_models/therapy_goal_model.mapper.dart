// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'therapy_goal_model.dart';

class TherapyGoalModelMapper extends ClassMapperBase<TherapyGoalModel> {
  TherapyGoalModelMapper._();

  static TherapyGoalModelMapper? _instance;
  static TherapyGoalModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TherapyGoalModelMapper._());
      TherapyModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TherapyGoalModel';

  static DateTime _$performedOn(TherapyGoalModel v) => v.performedOn;
  static const Field<TherapyGoalModel, DateTime> _f$performedOn = Field(
    'performedOn',
    _$performedOn,
    key: r'performed_on',
  );
  static String? _$therapistId(TherapyGoalModel v) => v.therapistId;
  static const Field<TherapyGoalModel, String> _f$therapistId = Field(
    'therapistId',
    _$therapistId,
    key: r'therapist_id',
    opt: true,
  );
  static String _$therapyTypeId(TherapyGoalModel v) => v.therapyTypeId;
  static const Field<TherapyGoalModel, String> _f$therapyTypeId = Field(
    'therapyTypeId',
    _$therapyTypeId,
    key: r'therapy_type_id',
  );
  static List<TherapyModel> _$goals(TherapyGoalModel v) => v.goals;
  static const Field<TherapyGoalModel, List<TherapyModel>> _f$goals = Field(
    'goals',
    _$goals,
  );
  static List<TherapyModel> _$observations(TherapyGoalModel v) =>
      v.observations;
  static const Field<TherapyGoalModel, List<TherapyModel>> _f$observations =
      Field('observations', _$observations);
  static List<TherapyModel> _$regressions(TherapyGoalModel v) => v.regressions;
  static const Field<TherapyGoalModel, List<TherapyModel>> _f$regressions =
      Field('regressions', _$regressions);
  static List<TherapyModel> _$activities(TherapyGoalModel v) => v.activities;
  static const Field<TherapyGoalModel, List<TherapyModel>> _f$activities =
      Field('activities', _$activities);
  static String? _$patientId(TherapyGoalModel v) => v.patientId;
  static const Field<TherapyGoalModel, String> _f$patientId = Field(
    'patientId',
    _$patientId,
    key: r'patient_id',
    opt: true,
  );
  static String? _$packageId(TherapyGoalModel v) => v.packageId;
  static const Field<TherapyGoalModel, String> _f$packageId = Field(
    'packageId',
    _$packageId,
    opt: true,
  );
  static String? _$patientPackageId(TherapyGoalModel v) => v.patientPackageId;
  static const Field<TherapyGoalModel, String> _f$patientPackageId = Field(
    'patientPackageId',
    _$patientPackageId,
    opt: true,
  );
  static String? _$sessionNotes(TherapyGoalModel v) => v.sessionNotes;
  static const Field<TherapyGoalModel, String> _f$sessionNotes = Field(
    'sessionNotes',
    _$sessionNotes,
    opt: true,
  );
  static Map<String, String>? _$goalAchievementStatus(TherapyGoalModel v) =>
      v.goalAchievementStatus;
  static const Field<TherapyGoalModel, Map<String, String>>
  _f$goalAchievementStatus = Field(
    'goalAchievementStatus',
    _$goalAchievementStatus,
    opt: true,
  );

  @override
  final MappableFields<TherapyGoalModel> fields = const {
    #performedOn: _f$performedOn,
    #therapistId: _f$therapistId,
    #therapyTypeId: _f$therapyTypeId,
    #goals: _f$goals,
    #observations: _f$observations,
    #regressions: _f$regressions,
    #activities: _f$activities,
    #patientId: _f$patientId,
    #packageId: _f$packageId,
    #patientPackageId: _f$patientPackageId,
    #sessionNotes: _f$sessionNotes,
    #goalAchievementStatus: _f$goalAchievementStatus,
  };

  static TherapyGoalModel _instantiate(DecodingData data) {
    return TherapyGoalModel(
      performedOn: data.dec(_f$performedOn),
      therapistId: data.dec(_f$therapistId),
      therapyTypeId: data.dec(_f$therapyTypeId),
      goals: data.dec(_f$goals),
      observations: data.dec(_f$observations),
      regressions: data.dec(_f$regressions),
      activities: data.dec(_f$activities),
      patientId: data.dec(_f$patientId),
      packageId: data.dec(_f$packageId),
      patientPackageId: data.dec(_f$patientPackageId),
      sessionNotes: data.dec(_f$sessionNotes),
      goalAchievementStatus: data.dec(_f$goalAchievementStatus),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TherapyGoalModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TherapyGoalModel>(map);
  }

  static TherapyGoalModel fromJson(String json) {
    return ensureInitialized().decodeJson<TherapyGoalModel>(json);
  }
}

mixin TherapyGoalModelMappable {
  String toJson() {
    return TherapyGoalModelMapper.ensureInitialized()
        .encodeJson<TherapyGoalModel>(this as TherapyGoalModel);
  }

  Map<String, dynamic> toMap() {
    return TherapyGoalModelMapper.ensureInitialized()
        .encodeMap<TherapyGoalModel>(this as TherapyGoalModel);
  }

  TherapyGoalModelCopyWith<TherapyGoalModel, TherapyGoalModel, TherapyGoalModel>
  get copyWith =>
      _TherapyGoalModelCopyWithImpl<TherapyGoalModel, TherapyGoalModel>(
        this as TherapyGoalModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return TherapyGoalModelMapper.ensureInitialized().stringifyValue(
      this as TherapyGoalModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TherapyGoalModelMapper.ensureInitialized().equalsValue(
      this as TherapyGoalModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TherapyGoalModelMapper.ensureInitialized().hashValue(
      this as TherapyGoalModel,
    );
  }
}

extension TherapyGoalModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TherapyGoalModel, $Out> {
  TherapyGoalModelCopyWith<$R, TherapyGoalModel, $Out>
  get $asTherapyGoalModel =>
      $base.as((v, t, t2) => _TherapyGoalModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TherapyGoalModelCopyWith<$R, $In extends TherapyGoalModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get goals;
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get observations;
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get regressions;
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get activities;
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get goalAchievementStatus;
  $R call({
    DateTime? performedOn,
    String? therapistId,
    String? therapyTypeId,
    List<TherapyModel>? goals,
    List<TherapyModel>? observations,
    List<TherapyModel>? regressions,
    List<TherapyModel>? activities,
    String? patientId,
    String? packageId,
    String? patientPackageId,
    String? sessionNotes,
    Map<String, String>? goalAchievementStatus,
  });
  TherapyGoalModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TherapyGoalModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TherapyGoalModel, $Out>
    implements TherapyGoalModelCopyWith<$R, TherapyGoalModel, $Out> {
  _TherapyGoalModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TherapyGoalModel> $mapper =
      TherapyGoalModelMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get goals => ListCopyWith(
    $value.goals,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(goals: v),
  );
  @override
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get observations => ListCopyWith(
    $value.observations,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(observations: v),
  );
  @override
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get regressions => ListCopyWith(
    $value.regressions,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(regressions: v),
  );
  @override
  ListCopyWith<
    $R,
    TherapyModel,
    TherapyModelCopyWith<$R, TherapyModel, TherapyModel>
  >
  get activities => ListCopyWith(
    $value.activities,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(activities: v),
  );
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get goalAchievementStatus => $value.goalAchievementStatus != null
      ? MapCopyWith(
          $value.goalAchievementStatus!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(goalAchievementStatus: v),
        )
      : null;
  @override
  $R call({
    DateTime? performedOn,
    Object? therapistId = $none,
    String? therapyTypeId,
    List<TherapyModel>? goals,
    List<TherapyModel>? observations,
    List<TherapyModel>? regressions,
    List<TherapyModel>? activities,
    Object? patientId = $none,
    Object? packageId = $none,
    Object? patientPackageId = $none,
    Object? sessionNotes = $none,
    Object? goalAchievementStatus = $none,
  }) => $apply(
    FieldCopyWithData({
      if (performedOn != null) #performedOn: performedOn,
      if (therapistId != $none) #therapistId: therapistId,
      if (therapyTypeId != null) #therapyTypeId: therapyTypeId,
      if (goals != null) #goals: goals,
      if (observations != null) #observations: observations,
      if (regressions != null) #regressions: regressions,
      if (activities != null) #activities: activities,
      if (patientId != $none) #patientId: patientId,
      if (packageId != $none) #packageId: packageId,
      if (patientPackageId != $none) #patientPackageId: patientPackageId,
      if (sessionNotes != $none) #sessionNotes: sessionNotes,
      if (goalAchievementStatus != $none)
        #goalAchievementStatus: goalAchievementStatus,
    }),
  );
  @override
  TherapyGoalModel $make(CopyWithData data) => TherapyGoalModel(
    performedOn: data.get(#performedOn, or: $value.performedOn),
    therapistId: data.get(#therapistId, or: $value.therapistId),
    therapyTypeId: data.get(#therapyTypeId, or: $value.therapyTypeId),
    goals: data.get(#goals, or: $value.goals),
    observations: data.get(#observations, or: $value.observations),
    regressions: data.get(#regressions, or: $value.regressions),
    activities: data.get(#activities, or: $value.activities),
    patientId: data.get(#patientId, or: $value.patientId),
    packageId: data.get(#packageId, or: $value.packageId),
    patientPackageId: data.get(#patientPackageId, or: $value.patientPackageId),
    sessionNotes: data.get(#sessionNotes, or: $value.sessionNotes),
    goalAchievementStatus: data.get(
      #goalAchievementStatus,
      or: $value.goalAchievementStatus,
    ),
  );

  @override
  TherapyGoalModelCopyWith<$R2, TherapyGoalModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TherapyGoalModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

