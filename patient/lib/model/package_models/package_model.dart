import 'package:dart_mappable/dart_mappable.dart';
import 'package:patient/model/package_models/package_therapy_details_model.dart';

part 'package_model.mapper.dart';

@MappableClass()
class PackageModel with PackageModelMappable {
  @MappableField(key: 'id')
  final String packageId;

  @MappableField(key: 'name')
  final String name;

  @MappableField(key: 'description')
  final String? description;

  @MappableField(key: 'price')
  final double? price;

  @MappableField(key: 'validity_days')
  final int? validityDays;

  @MappableField(key: 'is_active')
  final bool isActive;

  @MappableField(key: 'clinic_id')
  final String clinicId;

  @MappableField(key: 'therapy_details')
  final List<PackageTherapyDetailsModel>? therapyDetails;

  PackageModel({
    required this.packageId,
    required this.name,
    this.description,
    this.price,
    this.validityDays,
    required this.isActive,
    required this.clinicId,
    this.therapyDetails,
  });
}
