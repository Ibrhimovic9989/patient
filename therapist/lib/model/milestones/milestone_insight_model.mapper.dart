// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'milestone_insight_model.dart';

class MilestoneInsightModelMapper
    extends ClassMapperBase<MilestoneInsightModel> {
  MilestoneInsightModelMapper._();

  static MilestoneInsightModelMapper? _instance;
  static MilestoneInsightModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MilestoneInsightModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MilestoneInsightModel';

  static String _$title(MilestoneInsightModel v) => v.title;
  static const Field<MilestoneInsightModel, String> _f$title = Field(
    'title',
    _$title,
  );
  static String _$category(MilestoneInsightModel v) => v.category;
  static const Field<MilestoneInsightModel, String> _f$category = Field(
    'category',
    _$category,
  );
  static String _$status(MilestoneInsightModel v) => v.status;
  static const Field<MilestoneInsightModel, String> _f$status = Field(
    'status',
    _$status,
  );
  static String _$description(MilestoneInsightModel v) => v.description;
  static const Field<MilestoneInsightModel, String> _f$description = Field(
    'description',
    _$description,
  );
  static String _$evidence(MilestoneInsightModel v) => v.evidence;
  static const Field<MilestoneInsightModel, String> _f$evidence = Field(
    'evidence',
    _$evidence,
  );

  @override
  final MappableFields<MilestoneInsightModel> fields = const {
    #title: _f$title,
    #category: _f$category,
    #status: _f$status,
    #description: _f$description,
    #evidence: _f$evidence,
  };

  static MilestoneInsightModel _instantiate(DecodingData data) {
    return MilestoneInsightModel(
      title: data.dec(_f$title),
      category: data.dec(_f$category),
      status: data.dec(_f$status),
      description: data.dec(_f$description),
      evidence: data.dec(_f$evidence),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MilestoneInsightModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MilestoneInsightModel>(map);
  }

  static MilestoneInsightModel fromJson(String json) {
    return ensureInitialized().decodeJson<MilestoneInsightModel>(json);
  }
}

mixin MilestoneInsightModelMappable {
  String toJson() {
    return MilestoneInsightModelMapper.ensureInitialized()
        .encodeJson<MilestoneInsightModel>(this as MilestoneInsightModel);
  }

  Map<String, dynamic> toMap() {
    return MilestoneInsightModelMapper.ensureInitialized()
        .encodeMap<MilestoneInsightModel>(this as MilestoneInsightModel);
  }

  MilestoneInsightModelCopyWith<
    MilestoneInsightModel,
    MilestoneInsightModel,
    MilestoneInsightModel
  >
  get copyWith =>
      _MilestoneInsightModelCopyWithImpl<
        MilestoneInsightModel,
        MilestoneInsightModel
      >(this as MilestoneInsightModel, $identity, $identity);
  @override
  String toString() {
    return MilestoneInsightModelMapper.ensureInitialized().stringifyValue(
      this as MilestoneInsightModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return MilestoneInsightModelMapper.ensureInitialized().equalsValue(
      this as MilestoneInsightModel,
      other,
    );
  }

  @override
  int get hashCode {
    return MilestoneInsightModelMapper.ensureInitialized().hashValue(
      this as MilestoneInsightModel,
    );
  }
}

extension MilestoneInsightModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MilestoneInsightModel, $Out> {
  MilestoneInsightModelCopyWith<$R, MilestoneInsightModel, $Out>
  get $asMilestoneInsightModel => $base.as(
    (v, t, t2) => _MilestoneInsightModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MilestoneInsightModelCopyWith<
  $R,
  $In extends MilestoneInsightModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? title,
    String? category,
    String? status,
    String? description,
    String? evidence,
  });
  MilestoneInsightModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MilestoneInsightModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MilestoneInsightModel, $Out>
    implements MilestoneInsightModelCopyWith<$R, MilestoneInsightModel, $Out> {
  _MilestoneInsightModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MilestoneInsightModel> $mapper =
      MilestoneInsightModelMapper.ensureInitialized();
  @override
  $R call({
    String? title,
    String? category,
    String? status,
    String? description,
    String? evidence,
  }) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (category != null) #category: category,
      if (status != null) #status: status,
      if (description != null) #description: description,
      if (evidence != null) #evidence: evidence,
    }),
  );
  @override
  MilestoneInsightModel $make(CopyWithData data) => MilestoneInsightModel(
    title: data.get(#title, or: $value.title),
    category: data.get(#category, or: $value.category),
    status: data.get(#status, or: $value.status),
    description: data.get(#description, or: $value.description),
    evidence: data.get(#evidence, or: $value.evidence),
  );

  @override
  MilestoneInsightModelCopyWith<$R2, MilestoneInsightModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MilestoneInsightModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MilestoneAnalysisModelMapper
    extends ClassMapperBase<MilestoneAnalysisModel> {
  MilestoneAnalysisModelMapper._();

  static MilestoneAnalysisModelMapper? _instance;
  static MilestoneAnalysisModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MilestoneAnalysisModelMapper._());
      MilestoneInsightModelMapper.ensureInitialized();
      MilestoneTrendsModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'MilestoneAnalysisModel';

  static List<MilestoneInsightModel> _$milestones(MilestoneAnalysisModel v) =>
      v.milestones;
  static const Field<MilestoneAnalysisModel, List<MilestoneInsightModel>>
  _f$milestones = Field('milestones', _$milestones);
  static String _$progressSummary(MilestoneAnalysisModel v) =>
      v.progressSummary;
  static const Field<MilestoneAnalysisModel, String> _f$progressSummary = Field(
    'progressSummary',
    _$progressSummary,
  );
  static MilestoneTrendsModel _$trends(MilestoneAnalysisModel v) => v.trends;
  static const Field<MilestoneAnalysisModel, MilestoneTrendsModel> _f$trends =
      Field('trends', _$trends);
  static List<String> _$recommendations(MilestoneAnalysisModel v) =>
      v.recommendations;
  static const Field<MilestoneAnalysisModel, List<String>> _f$recommendations =
      Field('recommendations', _$recommendations);

  @override
  final MappableFields<MilestoneAnalysisModel> fields = const {
    #milestones: _f$milestones,
    #progressSummary: _f$progressSummary,
    #trends: _f$trends,
    #recommendations: _f$recommendations,
  };

  static MilestoneAnalysisModel _instantiate(DecodingData data) {
    return MilestoneAnalysisModel(
      milestones: data.dec(_f$milestones),
      progressSummary: data.dec(_f$progressSummary),
      trends: data.dec(_f$trends),
      recommendations: data.dec(_f$recommendations),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MilestoneAnalysisModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MilestoneAnalysisModel>(map);
  }

  static MilestoneAnalysisModel fromJson(String json) {
    return ensureInitialized().decodeJson<MilestoneAnalysisModel>(json);
  }
}

mixin MilestoneAnalysisModelMappable {
  String toJson() {
    return MilestoneAnalysisModelMapper.ensureInitialized()
        .encodeJson<MilestoneAnalysisModel>(this as MilestoneAnalysisModel);
  }

  Map<String, dynamic> toMap() {
    return MilestoneAnalysisModelMapper.ensureInitialized()
        .encodeMap<MilestoneAnalysisModel>(this as MilestoneAnalysisModel);
  }

  MilestoneAnalysisModelCopyWith<
    MilestoneAnalysisModel,
    MilestoneAnalysisModel,
    MilestoneAnalysisModel
  >
  get copyWith =>
      _MilestoneAnalysisModelCopyWithImpl<
        MilestoneAnalysisModel,
        MilestoneAnalysisModel
      >(this as MilestoneAnalysisModel, $identity, $identity);
  @override
  String toString() {
    return MilestoneAnalysisModelMapper.ensureInitialized().stringifyValue(
      this as MilestoneAnalysisModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return MilestoneAnalysisModelMapper.ensureInitialized().equalsValue(
      this as MilestoneAnalysisModel,
      other,
    );
  }

  @override
  int get hashCode {
    return MilestoneAnalysisModelMapper.ensureInitialized().hashValue(
      this as MilestoneAnalysisModel,
    );
  }
}

extension MilestoneAnalysisModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MilestoneAnalysisModel, $Out> {
  MilestoneAnalysisModelCopyWith<$R, MilestoneAnalysisModel, $Out>
  get $asMilestoneAnalysisModel => $base.as(
    (v, t, t2) => _MilestoneAnalysisModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MilestoneAnalysisModelCopyWith<
  $R,
  $In extends MilestoneAnalysisModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
    $R,
    MilestoneInsightModel,
    MilestoneInsightModelCopyWith<
      $R,
      MilestoneInsightModel,
      MilestoneInsightModel
    >
  >
  get milestones;
  MilestoneTrendsModelCopyWith<$R, MilestoneTrendsModel, MilestoneTrendsModel>
  get trends;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get recommendations;
  $R call({
    List<MilestoneInsightModel>? milestones,
    String? progressSummary,
    MilestoneTrendsModel? trends,
    List<String>? recommendations,
  });
  MilestoneAnalysisModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MilestoneAnalysisModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MilestoneAnalysisModel, $Out>
    implements
        MilestoneAnalysisModelCopyWith<$R, MilestoneAnalysisModel, $Out> {
  _MilestoneAnalysisModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MilestoneAnalysisModel> $mapper =
      MilestoneAnalysisModelMapper.ensureInitialized();
  @override
  ListCopyWith<
    $R,
    MilestoneInsightModel,
    MilestoneInsightModelCopyWith<
      $R,
      MilestoneInsightModel,
      MilestoneInsightModel
    >
  >
  get milestones => ListCopyWith(
    $value.milestones,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(milestones: v),
  );
  @override
  MilestoneTrendsModelCopyWith<$R, MilestoneTrendsModel, MilestoneTrendsModel>
  get trends => $value.trends.copyWith.$chain((v) => call(trends: v));
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>
  get recommendations => ListCopyWith(
    $value.recommendations,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(recommendations: v),
  );
  @override
  $R call({
    List<MilestoneInsightModel>? milestones,
    String? progressSummary,
    MilestoneTrendsModel? trends,
    List<String>? recommendations,
  }) => $apply(
    FieldCopyWithData({
      if (milestones != null) #milestones: milestones,
      if (progressSummary != null) #progressSummary: progressSummary,
      if (trends != null) #trends: trends,
      if (recommendations != null) #recommendations: recommendations,
    }),
  );
  @override
  MilestoneAnalysisModel $make(CopyWithData data) => MilestoneAnalysisModel(
    milestones: data.get(#milestones, or: $value.milestones),
    progressSummary: data.get(#progressSummary, or: $value.progressSummary),
    trends: data.get(#trends, or: $value.trends),
    recommendations: data.get(#recommendations, or: $value.recommendations),
  );

  @override
  MilestoneAnalysisModelCopyWith<$R2, MilestoneAnalysisModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MilestoneAnalysisModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class MilestoneTrendsModelMapper extends ClassMapperBase<MilestoneTrendsModel> {
  MilestoneTrendsModelMapper._();

  static MilestoneTrendsModelMapper? _instance;
  static MilestoneTrendsModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MilestoneTrendsModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MilestoneTrendsModel';

  static List<String> _$improving(MilestoneTrendsModel v) => v.improving;
  static const Field<MilestoneTrendsModel, List<String>> _f$improving = Field(
    'improving',
    _$improving,
  );
  static List<String> _$stable(MilestoneTrendsModel v) => v.stable;
  static const Field<MilestoneTrendsModel, List<String>> _f$stable = Field(
    'stable',
    _$stable,
  );
  static List<String> _$concerning(MilestoneTrendsModel v) => v.concerning;
  static const Field<MilestoneTrendsModel, List<String>> _f$concerning = Field(
    'concerning',
    _$concerning,
  );

  @override
  final MappableFields<MilestoneTrendsModel> fields = const {
    #improving: _f$improving,
    #stable: _f$stable,
    #concerning: _f$concerning,
  };

  static MilestoneTrendsModel _instantiate(DecodingData data) {
    return MilestoneTrendsModel(
      improving: data.dec(_f$improving),
      stable: data.dec(_f$stable),
      concerning: data.dec(_f$concerning),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static MilestoneTrendsModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MilestoneTrendsModel>(map);
  }

  static MilestoneTrendsModel fromJson(String json) {
    return ensureInitialized().decodeJson<MilestoneTrendsModel>(json);
  }
}

mixin MilestoneTrendsModelMappable {
  String toJson() {
    return MilestoneTrendsModelMapper.ensureInitialized()
        .encodeJson<MilestoneTrendsModel>(this as MilestoneTrendsModel);
  }

  Map<String, dynamic> toMap() {
    return MilestoneTrendsModelMapper.ensureInitialized()
        .encodeMap<MilestoneTrendsModel>(this as MilestoneTrendsModel);
  }

  MilestoneTrendsModelCopyWith<
    MilestoneTrendsModel,
    MilestoneTrendsModel,
    MilestoneTrendsModel
  >
  get copyWith =>
      _MilestoneTrendsModelCopyWithImpl<
        MilestoneTrendsModel,
        MilestoneTrendsModel
      >(this as MilestoneTrendsModel, $identity, $identity);
  @override
  String toString() {
    return MilestoneTrendsModelMapper.ensureInitialized().stringifyValue(
      this as MilestoneTrendsModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return MilestoneTrendsModelMapper.ensureInitialized().equalsValue(
      this as MilestoneTrendsModel,
      other,
    );
  }

  @override
  int get hashCode {
    return MilestoneTrendsModelMapper.ensureInitialized().hashValue(
      this as MilestoneTrendsModel,
    );
  }
}

extension MilestoneTrendsModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MilestoneTrendsModel, $Out> {
  MilestoneTrendsModelCopyWith<$R, MilestoneTrendsModel, $Out>
  get $asMilestoneTrendsModel => $base.as(
    (v, t, t2) => _MilestoneTrendsModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class MilestoneTrendsModelCopyWith<
  $R,
  $In extends MilestoneTrendsModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get improving;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get stable;
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get concerning;
  $R call({
    List<String>? improving,
    List<String>? stable,
    List<String>? concerning,
  });
  MilestoneTrendsModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _MilestoneTrendsModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MilestoneTrendsModel, $Out>
    implements MilestoneTrendsModelCopyWith<$R, MilestoneTrendsModel, $Out> {
  _MilestoneTrendsModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MilestoneTrendsModel> $mapper =
      MilestoneTrendsModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get improving =>
      ListCopyWith(
        $value.improving,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(improving: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get stable =>
      ListCopyWith(
        $value.stable,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(stable: v),
      );
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>> get concerning =>
      ListCopyWith(
        $value.concerning,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(concerning: v),
      );
  @override
  $R call({
    List<String>? improving,
    List<String>? stable,
    List<String>? concerning,
  }) => $apply(
    FieldCopyWithData({
      if (improving != null) #improving: improving,
      if (stable != null) #stable: stable,
      if (concerning != null) #concerning: concerning,
    }),
  );
  @override
  MilestoneTrendsModel $make(CopyWithData data) => MilestoneTrendsModel(
    improving: data.get(#improving, or: $value.improving),
    stable: data.get(#stable, or: $value.stable),
    concerning: data.get(#concerning, or: $value.concerning),
  );

  @override
  MilestoneTrendsModelCopyWith<$R2, MilestoneTrendsModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _MilestoneTrendsModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

