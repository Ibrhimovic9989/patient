// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'package_model.dart';

class PackageModelMapper extends ClassMapperBase<PackageModel> {
  PackageModelMapper._();

  static PackageModelMapper? _instance;
  static PackageModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PackageModelMapper._());
      PackageTherapyDetailsModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'PackageModel';

  static String _$packageId(PackageModel v) => v.packageId;
  static const Field<PackageModel, String> _f$packageId =
      Field('packageId', _$packageId, key: r'id');
  static String _$name(PackageModel v) => v.name;
  static const Field<PackageModel, String> _f$name = Field('name', _$name);
  static String? _$description(PackageModel v) => v.description;
  static const Field<PackageModel, String> _f$description =
      Field('description', _$description, opt: true);
  static double? _$price(PackageModel v) => v.price;
  static const Field<PackageModel, double> _f$price =
      Field('price', _$price, opt: true);
  static int? _$validityDays(PackageModel v) => v.validityDays;
  static const Field<PackageModel, int> _f$validityDays =
      Field('validityDays', _$validityDays, key: r'validity_days', opt: true);
  static bool _$isActive(PackageModel v) => v.isActive;
  static const Field<PackageModel, bool> _f$isActive =
      Field('isActive', _$isActive, key: r'is_active');
  static String _$clinicId(PackageModel v) => v.clinicId;
  static const Field<PackageModel, String> _f$clinicId =
      Field('clinicId', _$clinicId, key: r'clinic_id');
  static List<PackageTherapyDetailsModel>? _$therapyDetails(PackageModel v) =>
      v.therapyDetails;
  static const Field<PackageModel, List<PackageTherapyDetailsModel>>
      _f$therapyDetails = Field('therapyDetails', _$therapyDetails,
          key: r'therapy_details', opt: true);

  @override
  final MappableFields<PackageModel> fields = const {
    #packageId: _f$packageId,
    #name: _f$name,
    #description: _f$description,
    #price: _f$price,
    #validityDays: _f$validityDays,
    #isActive: _f$isActive,
    #clinicId: _f$clinicId,
    #therapyDetails: _f$therapyDetails,
  };

  static PackageModel _instantiate(DecodingData data) {
    return PackageModel(
        packageId: data.dec(_f$packageId),
        name: data.dec(_f$name),
        description: data.dec(_f$description),
        price: data.dec(_f$price),
        validityDays: data.dec(_f$validityDays),
        isActive: data.dec(_f$isActive),
        clinicId: data.dec(_f$clinicId),
        therapyDetails: data.dec(_f$therapyDetails));
  }

  @override
  final Function instantiate = _instantiate;

  static PackageModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<PackageModel>(map);
  }

  static PackageModel fromJson(String json) {
    return ensureInitialized().decodeJson<PackageModel>(json);
  }
}

mixin PackageModelMappable {
  String toJson() {
    return PackageModelMapper.ensureInitialized()
        .encodeJson<PackageModel>(this as PackageModel);
  }

  Map<String, dynamic> toMap() {
    return PackageModelMapper.ensureInitialized()
        .encodeMap<PackageModel>(this as PackageModel);
  }

  PackageModelCopyWith<PackageModel, PackageModel, PackageModel> get copyWith =>
      _PackageModelCopyWithImpl<PackageModel, PackageModel>(
          this as PackageModel, $identity, $identity);
  @override
  String toString() {
    return PackageModelMapper.ensureInitialized()
        .stringifyValue(this as PackageModel);
  }

  @override
  bool operator ==(Object other) {
    return PackageModelMapper.ensureInitialized()
        .equalsValue(this as PackageModel, other);
  }

  @override
  int get hashCode {
    return PackageModelMapper.ensureInitialized()
        .hashValue(this as PackageModel);
  }
}

extension PackageModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, PackageModel, $Out> {
  PackageModelCopyWith<$R, PackageModel, $Out> get $asPackageModel =>
      $base.as((v, t, t2) => _PackageModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class PackageModelCopyWith<$R, $In extends PackageModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<
      $R,
      PackageTherapyDetailsModel,
      PackageTherapyDetailsModelCopyWith<$R, PackageTherapyDetailsModel,
          PackageTherapyDetailsModel>>? get therapyDetails;
  $R call(
      {String? packageId,
      String? name,
      String? description,
      double? price,
      int? validityDays,
      bool? isActive,
      String? clinicId,
      List<PackageTherapyDetailsModel>? therapyDetails});
  PackageModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PackageModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, PackageModel, $Out>
    implements PackageModelCopyWith<$R, PackageModel, $Out> {
  _PackageModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<PackageModel> $mapper =
      PackageModelMapper.ensureInitialized();
  @override
  ListCopyWith<
      $R,
      PackageTherapyDetailsModel,
      PackageTherapyDetailsModelCopyWith<$R, PackageTherapyDetailsModel,
          PackageTherapyDetailsModel>>? get therapyDetails =>
      $value.therapyDetails != null
          ? ListCopyWith($value.therapyDetails!, (v, t) => v.copyWith.$chain(t),
              (v) => call(therapyDetails: v))
          : null;
  @override
  $R call(
          {String? packageId,
          String? name,
          Object? description = $none,
          Object? price = $none,
          Object? validityDays = $none,
          bool? isActive,
          String? clinicId,
          Object? therapyDetails = $none}) =>
      $apply(FieldCopyWithData({
        if (packageId != null) #packageId: packageId,
        if (name != null) #name: name,
        if (description != $none) #description: description,
        if (price != $none) #price: price,
        if (validityDays != $none) #validityDays: validityDays,
        if (isActive != null) #isActive: isActive,
        if (clinicId != null) #clinicId: clinicId,
        if (therapyDetails != $none) #therapyDetails: therapyDetails
      }));
  @override
  PackageModel $make(CopyWithData data) => PackageModel(
      packageId: data.get(#packageId, or: $value.packageId),
      name: data.get(#name, or: $value.name),
      description: data.get(#description, or: $value.description),
      price: data.get(#price, or: $value.price),
      validityDays: data.get(#validityDays, or: $value.validityDays),
      isActive: data.get(#isActive, or: $value.isActive),
      clinicId: data.get(#clinicId, or: $value.clinicId),
      therapyDetails: data.get(#therapyDetails, or: $value.therapyDetails));

  @override
  PackageModelCopyWith<$R2, PackageModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _PackageModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
