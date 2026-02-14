import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapist/core/entities/consultation/consultation_request_entity.dart';
import 'package:therapist/core/repository/consultation/consultation_repository.dart';
import 'package:therapist/core/result/result.dart';

class SupabaseConsultationRepository implements ConsultationRepository {
  // Make the parameter optional with "?"
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  // Accept nullable client
  SupabaseConsultationRepository();
  

  @override
  Future<ActionResult> fetchConsultationRequests() async {
    try {
      // First get therapist's clinic_id
      final therapistResponse = await _supabaseClient
          .from('therapist')
          .select('clinic_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (therapistResponse == null || therapistResponse['clinic_id'] == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist not assigned to a clinic',
          statusCode: 404,
        );
      }

      final clinicId = therapistResponse['clinic_id'];

      final response = await _supabaseClient
          .from('session')
          .select('*, patient (patient_name)')
          .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
          .eq('is_consultation', true)
          .eq('clinic_id', clinicId); // Filter by clinic

      if (response.isEmpty) {
        return ActionResultSuccess(data: <dynamic>[], statusCode: 200);
      }

      final data = response as List<dynamic>;

      final consultationData = data.map((session) {
        return ConsultationRequestEntity(
          id: session['id'],
          patientName: session['patient'] != null 
              ? (session['patient'] as Map<String, dynamic>)['patient_name'] ?? ''
              : '',
          timestamp: session['timestamp'],
          therapistId: session['therapist_id'],
          patientId: session['patient_id'],
          isConsultation: session['is_consultation'],
          mode: session['mode'],
          duration: session['duration'],
          name: session['name'],
          status: session['status'],
        ).toModel();
      }).toList();

      return ActionResultSuccess(data: consultationData, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(
        errorMessage: 'Failed to fetch consultation requests: ${e.toString()}',
        statusCode: 500
      );
    }
  }

  @override
  Future<ActionResult> getConsultationRequestById(String requestId) async {
  
      return ActionResultSuccess(data: '', statusCode: 200);
  }

  @override
  Future<ActionResult> updateRequestStatus({
    required String requestId,
    required String status,
    String? reason,
    DateTime? scheduledTime,
    String? notes,
  }) async {
    try {
      
      await _supabaseClient
        .from('session')
        .update({
          'status': status,
          'declined_reason': reason,
        })
        .eq('id', requestId);

      return ActionResultSuccess(
        data: 'Consultation request status updated successfully', 
        statusCode: 200
      );
    } catch (e) {
      return ActionResultFailure(
        errorMessage: 'Failed to update request status: ${e.toString()}',
        statusCode: 400
      );
    }
  }
}