import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicRepository {
  final SupabaseClient _supabase;

  ClinicRepository(this._supabase);

  // Get current clinic info
  Future<Map<String, dynamic>?> getCurrentClinic() async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) return null;

    final response = await _supabase
        .from('clinic')
        .select('*')
        .eq('owner_email', email)
        .maybeSingle();

    return response;
  }

  // Get clinic subscription
  Future<Map<String, dynamic>?> getClinicSubscription(String clinicId) async {
    final response = await _supabase
        .from('clinic_subscription')
        .select('*')
        .eq('clinic_id', clinicId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .maybeSingle();

    return response;
  }

  // Get all packages for clinic
  Future<List<Map<String, dynamic>>> getClinicPackages(String clinicId) async {
    final response = await _supabase
        .from('package')
        .select('*')
        .eq('clinic_id', clinicId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get package with therapy details
  Future<Map<String, dynamic>?> getPackageWithDetails(String packageId) async {
    final package = await _supabase
        .from('package')
        .select('*')
        .eq('id', packageId)
        .maybeSingle();

    if (package == null) return null;

    final therapyDetails = await _supabase
        .from('package_therapy_details')
        .select('*, therapy:therapy_id(*)')
        .eq('package_id', packageId);

    return {
      ...package,
      'therapy_details': therapyDetails,
    };
  }

  // Create package
  Future<Map<String, dynamic>> createPackage({
    required String clinicId,
    required String name,
    required double price,
    required int validityDays,
    String? description,
    required List<Map<String, dynamic>> therapyDetails,
  }) async {
    // Insert package
    // Note: duration is required by schema, using validityDays as duration
    final packageResponse = await _supabase
        .from('package')
        .insert({
          'clinic_id': clinicId,
          'name': name,
          'duration': validityDays, // duration is required, using validityDays
          'price': price,
          'validity_days': validityDays,
          'description': description,
          'is_active': true,
        })
        .select()
        .single();

    final packageId = packageResponse['id'] as String;

    // Insert therapy details
    if (therapyDetails.isNotEmpty) {
      await _supabase
          .from('package_therapy_details')
          .insert(
            therapyDetails.map((detail) => {
              ...detail,
              'package_id': packageId,
            }).toList(),
          );
    }

    return packageResponse;
  }

  // Update package
  Future<void> updatePackage({
    required String packageId,
    String? name,
    double? price,
    int? validityDays,
    String? description,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (price != null) updateData['price'] = price;
    if (validityDays != null) {
      updateData['validity_days'] = validityDays;
      updateData['duration'] = validityDays; // duration is required, sync with validityDays
    }
    if (description != null) updateData['description'] = description;
    if (isActive != null) updateData['is_active'] = isActive;

    if (updateData.isNotEmpty) {
      await _supabase
          .from('package')
          .update(updateData)
          .eq('id', packageId);
    }
  }

  // Delete package
  Future<void> deletePackage(String packageId) async {
    await _supabase.from('package').delete().eq('id', packageId);
  }

  // Get all therapy types
  Future<List<Map<String, dynamic>>> getTherapyTypes() async {
    final response = await _supabase
        .from('therapy')
        .select('*')
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Assign therapist to patient for a specific therapy type
  Future<Map<String, dynamic>> assignTherapistToPatient({
    required String patientId,
    required String therapistId,
    required String therapyTypeId,
    required String patientPackageId,
  }) async {
    // 1. Validate therapist offers this therapy type
    final therapist = await _supabase
        .from('therapist')
        .select('offered_therapies')
        .eq('id', therapistId)
        .single();

    final offeredTherapies = List<String>.from(therapist['offered_therapies'] ?? []);
    if (!offeredTherapies.contains(therapyTypeId)) {
      throw Exception('Therapist does not offer this therapy type');
    }

    // 2. Check if assignment already exists
    final existing = await _supabase
        .from('patient_therapist_assignment')
        .select('id')
        .eq('patient_id', patientId)
        .eq('therapy_type_id', therapyTypeId)
        .eq('patient_package_id', patientPackageId)
        .maybeSingle();

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (existing != null) {
      // Update existing assignment
      await _supabase
          .from('patient_therapist_assignment')
          .update({
            'therapist_id': therapistId,
            'assigned_by': userId,
            'assigned_at': DateTime.now().toIso8601String(),
            'is_active': true,
          })
          .eq('id', existing['id']);
    } else {
      // Create new assignment
      await _supabase
          .from('patient_therapist_assignment')
          .insert({
            'patient_id': patientId,
            'therapist_id': therapistId,
            'therapy_type_id': therapyTypeId,
            'patient_package_id': patientPackageId,
            'assigned_by': userId,
            'is_active': true,
          });
    }

    return {'success': true};
  }
}
