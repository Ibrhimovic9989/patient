import 'package:dart_mappable/dart_mappable.dart';

part 'therapist_patient_details_entity.mapper.dart';

// Entity class that resembles therapist's patient details information with Supabase [PATIENTS] table
// This class can have toModel and fromModel methods to convert to and from model

@MappableClass()
class TherapistPatientDetailsEntity with TherapistPatientDetailsEntityMappable {

  @MappableField(key: 'id')
  final String patientId;

  @MappableField(key: 'name')
  final String patientName;

  @MappableField(key: 'age')
  final int? age;

  @MappableField(key: 'email')
  final String email;

  @MappableField(key: 'phone')
  final String phoneNo;

  @MappableField(key: 'is_adult')
  final bool isAdult;

  @MappableField(key: 'guardian_name')
  final String? guardianName;

  @MappableField(key: 'guardian_relation')
  final String? guardianRelation;
  
  @MappableField(key: 'autism_level')
  final int? autismLevel;

  @MappableField(key: 'onboarded_on')
  final DateTime? onboardedOn;

  @MappableField(key: 'therapist_id')
  final String? therapistId;

  @MappableField(key: 'gender')
  final String? gender;

  @MappableField(key: 'country')
  final String? country;

  // Package information
  @MappableField(key: 'package_name')
  final String? packageName;

  @MappableField(key: 'package_id')
  final String? packageId;

  @MappableField(key: 'package_expires_at')
  final DateTime? packageExpiresAt;

  @MappableField(key: 'package_status')
  final String? packageStatus;

  @MappableField(key: 'package_therapy_types')
  final List<String>? packageTherapyTypes;

  @MappableField(key: 'session_usage')
  final Map<String, Map<String, int>>? sessionUsage;


  TherapistPatientDetailsEntity({
    required this.patientId,
    required this.patientName,
    required this.email,
    required this.phoneNo,
    required this.isAdult,
    this.age,
    this.guardianName,
    this.guardianRelation,
    this.autismLevel,
    this.onboardedOn,
    this.therapistId,
    this.gender,
    this.country,
    this.packageName,
    this.packageId,
    this.packageExpiresAt,
    this.packageStatus,
    this.packageTherapyTypes,
    this.sessionUsage,
  });



}