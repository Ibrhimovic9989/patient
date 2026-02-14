// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'package_therapy_details_model.dart';

class PackageTherapyDetailsModelMapper
    extends ClassMapperBase<PackageTherapyDetailsModel> {
  PackageTherapyDetailsModelMapper._();

  static PackageTherapyDetailsModelMapper? _instance;
  static PackageTherapyDetailsModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals
          .use(_instance = PackageTherapyDetailsModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'PackageTherapyDetailsModel';

  static String _$id(PackageTherapyDetailsModel v) => v.id;
  static const Field<PackageTherapyDetailsModel, String> _f$id =
      Field('id', _$id);
  static String _$therapyTypeId(PackageTherapyDetailsModel v) =>
      v.therapyTypeId;
  static const Field<PackageTherapyDetailsModel, String> _f$therapyTypeId =
      Field('therapyTypeId', _$therapyTypeId, key: r'therapy_type_id');
  static String? _$therapyName(PackageTherapyDetailsModel v) => v.therapyName;
  static const Field<PackageTherapyDetailsModel, String> _f$therapyName =
      Field('therapyName', _$therapyName, key: r'therapy_name', opt: true);
  static int _$sessionCount(PackageTherapyDetailsModel v) => v.sessionCount;
  static const Field<PackageTherapyDetailsModel, int> _f$sessionCount =
      Field('sessionCount', _$sessionCount, key: r'session_count');
  static int? _$frequencyPerWeek(PackageTherapyDetailsModel v) =>
      v.frequencyPerWeek;
  static const Field<PackageTherapyDetailsModel, int> _f$frequencyPerWeek =
      Field('frequencyPerWeek', _$frequencyPerWeek,
          key: r'frequency_per_week', opt: true);
  static int? _$sessionDurationMinutes(PackageTherapyDetailsModel v) =>
      v.sessionDurationMinutes;
  static const Field<PackageTherapyDetailsModel, int>
      _f$sessionDurationMinutes = Field(
          'sessionDurationMinutes', _$sessionDurationMinutes,
          key: r'session_duration_minutes', opt: true);

  @override
  final MappableFields<PackageTherapyDetailsModel> fields = const {
    #id: _f$id,
    #therapyTypeId: _f$therapyTypeId,
    #therapyName: _f$therapyName,
    #sessionCount: _f$sessionCount,
    #frequencyPerWeek: _f$frequencyPerWeek,
    #sessionDurationMinutes: _f$sessionDurationMinutes,
  };

  static PackageTherapyDetailsModel _instantiate(DecodingData data) {
    return PackageTherapyDetailsModel(
        id: data.dec(_f$id),
        therapyTypeId: data.dec(_f$therapyTypeId),
        therapyName: data.dec(_f$therapyName),
        sessionCount: data.dec(_f$sessionCount),
        frequencyPerWeek: data.dec(_f$frequencyPerWeek),
        sessionDurationMinutes: data.dec(_f$sessionDurationMinutes));
  }

  @override
  final Function instantiate = _instantiate;

  static PackageTherapyDetailsModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PackageTherapyDetailsModel>(map);
  }

  static PackageTherapyDetailsModel fromJson(String json) {
    return ensureInitialized().decodeJson<PackageTherapyDetailsModel>(json);
  }
}

mixin PackageTherapyDetailsModelMappable {
  String toJson() {
    return PackageTherapyDetailsModelMapper.ensureInitialized()
        .encodeJson<PackageTherapyDetailsModel>(
            this as PackageTherapyDetailsModel);
  }

  Map<String, dynamic> toMap() {
    return PackageTherapyDetailsModelMapper.ensureInitialized()
        .encodeMap<PackageTherapyDetailsModel>(
            this as PackageTherapyDetailsModel);
  }

  PackageTherapyDetailsModelCopyWith<PackageTherapyDetailsModel,
          PackageTherapyDetailsModel, PackageTherapyDetailsModel>
      get copyWith => _PackageTherapyDetailsModelCopyWithImpl<
              PackageTherapyDetailsModel, PackageTherapyDetailsModel>(
          this as PackageTherapyDetailsModel, $identity, $identity);
  @override
  String toString() {
    return PackageTherapyDetailsModelMapper.ensureInitialized()
        .stringifyValue(this as PackageTherapyDetailsModel);
  }

  @override
  bool operator ==(Object other) {
    return PackageTherapyDetailsModelMapper.ensureInitialized()
        .equalsValue(this as PackageTherapyDetailsModel, other);
  }

  @override
  int get hashCode {
    return PackageTherapyDetailsModelMapper.ensureInitialized()
        .hashValue(this as PackageTherapyDetailsModel);
  }
}

extension PackageTherapyDetailsModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PackageTherapyDetailsModel, $Out> {
  PackageTherapyDetailsModelCopyWith<$R, PackageTherapyDetailsModel, $Out>
      get $asPackageTherapyDetailsModel => $base.as((v, t, t2) =>
          _PackageTherapyDetailsModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PackageTherapyDetailsModelCopyWith<
    $R,
    $In extends PackageTherapyDetailsModel,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? id,
      String? therapyTypeId,
      String? therapyName,
      int? sessionCount,
      int? frequencyPerWeek,
      int? sessionDurationMinutes});
  PackageTherapyDetailsModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _PackageTherapyDetailsModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PackageTherapyDetailsModel, $Out>
    implements
        PackageTherapyDetailsModelCopyWith<$R, PackageTherapyDetailsModel,
            $Out> {
  _PackageTherapyDetailsModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PackageTherapyDetailsModel> $mapper =
      PackageTherapyDetailsModelMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? therapyTypeId,
          Object? therapyName = $none,
          int? sessionCount,
          Object? frequencyPerWeek = $none,
          Object? sessionDurationMinutes = $none}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (therapyTypeId != null) #therapyTypeId: therapyTypeId,
        if (therapyName != $none) #therapyName: therapyName,
        if (sessionCount != null) #sessionCount: sessionCount,
        if (frequencyPerWeek != $none) #frequencyPerWeek: frequencyPerWeek,
        if (sessionDurationMinutes != $none)
          #sessionDurationMinutes: sessionDurationMinutes
      }));
  @override
  PackageTherapyDetailsModel $make(
          CopyWithData data) =>
      PackageTherapyDetailsModel(
          id: data.get(#id, or: $value.id),
          therapyTypeId: data.get(#therapyTypeId, or: $value.therapyTypeId),
          therapyName: data.get(#therapyName, or: $value.therapyName),
          sessionCount: data.get(#sessionCount, or: $value.sessionCount),
          frequencyPerWeek:
              data.get(#frequencyPerWeek, or: $value.frequencyPerWeek),
          sessionDurationMinutes: data.get(#sessionDurationMinutes,
              or: $value.sessionDurationMinutes));

  @override
  PackageTherapyDetailsModelCopyWith<$R2, PackageTherapyDetailsModel, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _PackageTherapyDetailsModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
