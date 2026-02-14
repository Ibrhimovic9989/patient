// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'therapist_patient_details_model.dart';

class TherapistPatientDetailsModelMapper
    extends ClassMapperBase<TherapistPatientDetailsModel> {
  TherapistPatientDetailsModelMapper._();

  static TherapistPatientDetailsModelMapper? _instance;
  static TherapistPatientDetailsModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(
        _instance = TherapistPatientDetailsModelMapper._(),
      );
    }
    return _instance!;
  }

  @override
  final String id = 'TherapistPatientDetailsModel';

  static String _$patientId(TherapistPatientDetailsModel v) => v.patientId;
  static const Field<TherapistPatientDetailsModel, String> _f$patientId = Field(
    'patientId',
    _$patientId,
    key: r'id',
  );
  static String _$patientName(TherapistPatientDetailsModel v) => v.patientName;
  static const Field<TherapistPatientDetailsModel, String> _f$patientName =
      Field('patientName', _$patientName, key: r'patient_name');
  static String _$phoneNo(TherapistPatientDetailsModel v) => v.phoneNo;
  static const Field<TherapistPatientDetailsModel, String> _f$phoneNo = Field(
    'phoneNo',
    _$phoneNo,
    key: r'phone',
  );
  static String _$email(TherapistPatientDetailsModel v) => v.email;
  static const Field<TherapistPatientDetailsModel, String> _f$email = Field(
    'email',
    _$email,
  );
  static String? _$packageName(TherapistPatientDetailsModel v) => v.packageName;
  static const Field<TherapistPatientDetailsModel, String> _f$packageName =
      Field('packageName', _$packageName, opt: true);
  static String? _$packageId(TherapistPatientDetailsModel v) => v.packageId;
  static const Field<TherapistPatientDetailsModel, String> _f$packageId = Field(
    'packageId',
    _$packageId,
    opt: true,
  );
  static DateTime? _$packageExpiresAt(TherapistPatientDetailsModel v) =>
      v.packageExpiresAt;
  static const Field<TherapistPatientDetailsModel, DateTime>
  _f$packageExpiresAt = Field(
    'packageExpiresAt',
    _$packageExpiresAt,
    opt: true,
  );
  static String? _$packageStatus(TherapistPatientDetailsModel v) =>
      v.packageStatus;
  static const Field<TherapistPatientDetailsModel, String> _f$packageStatus =
      Field('packageStatus', _$packageStatus, opt: true);
  static List<String>? _$packageTherapyTypes(TherapistPatientDetailsModel v) =>
      v.packageTherapyTypes;
  static const Field<TherapistPatientDetailsModel, List<String>>
  _f$packageTherapyTypes = Field(
    'packageTherapyTypes',
    _$packageTherapyTypes,
    opt: true,
  );
  static Map<String, Map<String, int>>? _$sessionUsage(
    TherapistPatientDetailsModel v,
  ) => v.sessionUsage;
  static const Field<
    TherapistPatientDetailsModel,
    Map<String, Map<String, int>>
  >
  _f$sessionUsage = Field('sessionUsage', _$sessionUsage, opt: true);

  @override
  final MappableFields<TherapistPatientDetailsModel> fields = const {
    #patientId: _f$patientId,
    #patientName: _f$patientName,
    #phoneNo: _f$phoneNo,
    #email: _f$email,
    #packageName: _f$packageName,
    #packageId: _f$packageId,
    #packageExpiresAt: _f$packageExpiresAt,
    #packageStatus: _f$packageStatus,
    #packageTherapyTypes: _f$packageTherapyTypes,
    #sessionUsage: _f$sessionUsage,
  };

  static TherapistPatientDetailsModel _instantiate(DecodingData data) {
    return TherapistPatientDetailsModel(
      patientId: data.dec(_f$patientId),
      patientName: data.dec(_f$patientName),
      phoneNo: data.dec(_f$phoneNo),
      email: data.dec(_f$email),
      packageName: data.dec(_f$packageName),
      packageId: data.dec(_f$packageId),
      packageExpiresAt: data.dec(_f$packageExpiresAt),
      packageStatus: data.dec(_f$packageStatus),
      packageTherapyTypes: data.dec(_f$packageTherapyTypes),
      sessionUsage: data.dec(_f$sessionUsage),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TherapistPatientDetailsModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TherapistPatientDetailsModel>(map);
  }

  static TherapistPatientDetailsModel fromJson(String json) {
    return ensureInitialized().decodeJson<TherapistPatientDetailsModel>(json);
  }
}

mixin TherapistPatientDetailsModelMappable {
  String toJson() {
    return TherapistPatientDetailsModelMapper.ensureInitialized()
        .encodeJson<TherapistPatientDetailsModel>(
          this as TherapistPatientDetailsModel,
        );
  }

  Map<String, dynamic> toMap() {
    return TherapistPatientDetailsModelMapper.ensureInitialized()
        .encodeMap<TherapistPatientDetailsModel>(
          this as TherapistPatientDetailsModel,
        );
  }

  TherapistPatientDetailsModelCopyWith<
    TherapistPatientDetailsModel,
    TherapistPatientDetailsModel,
    TherapistPatientDetailsModel
  >
  get copyWith =>
      _TherapistPatientDetailsModelCopyWithImpl<
        TherapistPatientDetailsModel,
        TherapistPatientDetailsModel
      >(this as TherapistPatientDetailsModel, $identity, $identity);
  @override
  String toString() {
    return TherapistPatientDetailsModelMapper.ensureInitialized()
        .stringifyValue(this as TherapistPatientDetailsModel);
  }

  @override
  bool operator ==(Object other) {
    return TherapistPatientDetailsModelMapper.ensureInitialized().equalsValue(
      this as TherapistPatientDetailsModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TherapistPatientDetailsModelMapper.ensureInitialized().hashValue(
      this as TherapistPatientDetailsModel,
    );
  }
}

extension TherapistPatientDetailsModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TherapistPatientDetailsModel, $Out> {
  TherapistPatientDetailsModelCopyWith<$R, TherapistPatientDetailsModel, $Out>
  get $asTherapistPatientDetailsModel => $base.as(
    (v, t, t2) => _TherapistPatientDetailsModelCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class TherapistPatientDetailsModelCopyWith<
  $R,
  $In extends TherapistPatientDetailsModel,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get packageTherapyTypes;
  MapCopyWith<
    $R,
    String,
    Map<String, int>,
    ObjectCopyWith<$R, Map<String, int>, Map<String, int>>
  >?
  get sessionUsage;
  $R call({
    String? patientId,
    String? patientName,
    String? phoneNo,
    String? email,
    String? packageName,
    String? packageId,
    DateTime? packageExpiresAt,
    String? packageStatus,
    List<String>? packageTherapyTypes,
    Map<String, Map<String, int>>? sessionUsage,
  });
  TherapistPatientDetailsModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TherapistPatientDetailsModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TherapistPatientDetailsModel, $Out>
    implements
        TherapistPatientDetailsModelCopyWith<
          $R,
          TherapistPatientDetailsModel,
          $Out
        > {
  _TherapistPatientDetailsModelCopyWithImpl(
    super.value,
    super.then,
    super.then2,
  );

  @override
  late final ClassMapperBase<TherapistPatientDetailsModel> $mapper =
      TherapistPatientDetailsModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, String, ObjectCopyWith<$R, String, String>>?
  get packageTherapyTypes => $value.packageTherapyTypes != null
      ? ListCopyWith(
          $value.packageTherapyTypes!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(packageTherapyTypes: v),
        )
      : null;
  @override
  MapCopyWith<
    $R,
    String,
    Map<String, int>,
    ObjectCopyWith<$R, Map<String, int>, Map<String, int>>
  >?
  get sessionUsage => $value.sessionUsage != null
      ? MapCopyWith(
          $value.sessionUsage!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(sessionUsage: v),
        )
      : null;
  @override
  $R call({
    String? patientId,
    String? patientName,
    String? phoneNo,
    String? email,
    Object? packageName = $none,
    Object? packageId = $none,
    Object? packageExpiresAt = $none,
    Object? packageStatus = $none,
    Object? packageTherapyTypes = $none,
    Object? sessionUsage = $none,
  }) => $apply(
    FieldCopyWithData({
      if (patientId != null) #patientId: patientId,
      if (patientName != null) #patientName: patientName,
      if (phoneNo != null) #phoneNo: phoneNo,
      if (email != null) #email: email,
      if (packageName != $none) #packageName: packageName,
      if (packageId != $none) #packageId: packageId,
      if (packageExpiresAt != $none) #packageExpiresAt: packageExpiresAt,
      if (packageStatus != $none) #packageStatus: packageStatus,
      if (packageTherapyTypes != $none)
        #packageTherapyTypes: packageTherapyTypes,
      if (sessionUsage != $none) #sessionUsage: sessionUsage,
    }),
  );
  @override
  TherapistPatientDetailsModel $make(CopyWithData data) =>
      TherapistPatientDetailsModel(
        patientId: data.get(#patientId, or: $value.patientId),
        patientName: data.get(#patientName, or: $value.patientName),
        phoneNo: data.get(#phoneNo, or: $value.phoneNo),
        email: data.get(#email, or: $value.email),
        packageName: data.get(#packageName, or: $value.packageName),
        packageId: data.get(#packageId, or: $value.packageId),
        packageExpiresAt: data.get(
          #packageExpiresAt,
          or: $value.packageExpiresAt,
        ),
        packageStatus: data.get(#packageStatus, or: $value.packageStatus),
        packageTherapyTypes: data.get(
          #packageTherapyTypes,
          or: $value.packageTherapyTypes,
        ),
        sessionUsage: data.get(#sessionUsage, or: $value.sessionUsage),
      );

  @override
  TherapistPatientDetailsModelCopyWith<$R2, TherapistPatientDetailsModel, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _TherapistPatientDetailsModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

