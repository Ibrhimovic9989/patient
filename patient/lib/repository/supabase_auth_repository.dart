import 'package:flutter/material.dart';
import 'package:patient/core/entities/auth_entities/auth_entities.dart';
import 'package:patient/core/repository/auth/auth_repository.dart';
import 'package:patient/core/result/result.dart';
import 'package:patient/model/auth_models/auth_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ActionResult> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<ActionResult> storePersonalInfo(
      PersonalInfoEntity personalInfoEntity) async {
    try {
      final patientId = _supabaseClient.auth.currentSession?.user.id;
      await _supabaseClient
          .from('patient')
          .insert(personalInfoEntity.copyWith(patientId: patientId).toMap());

      return ActionResultSuccess(
          data: 'Personal information stored successfully', statusCode: 200);
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<ActionResult> checkIfPatientExists() async {
    try {
      final response = await _supabaseClient
          .from('patient')
          .select('*')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (response != null) {
        return ActionResultSuccess(data: true, statusCode: 200);
      } else {
        return ActionResultSuccess(data: false, statusCode: 400);
      }
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<ActionResult> getAllAvailableTherapist() async {
    try {
      // First, get the patient's clinic_id
      final patientResponse = await _supabaseClient
          .from('patient')
          .select('clinic_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (patientResponse == null || patientResponse['clinic_id'] == null) {
        return ActionResultFailure(
          errorMessage: 'Patient is not associated with a clinic',
          statusCode: 400,
        );
      }

      final clinicId = patientResponse['clinic_id'] as String;

      // Get therapists from the same clinic
      final response = await _supabaseClient
          .from('therapist')
          .select('*')
          .eq('approved', true)
          .eq('clinic_id', clinicId);

      if (response.isNotEmpty) {
        final therapistData = response
            .map((e) => TherapistEntityMapper.fromMap(e).toModel())
            .toList();
        return ActionResultSuccess(data: therapistData, statusCode: 200);
      } else {
        return ActionResultSuccess(data: <TherapistModel>[], statusCode: 200);
      }
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<ActionResult> getAvailableBookingSlotsForTherapist(
    String therapistId,
    DateTime date,
    String startTimeOfTherapist,
    String endTimeOfTherapist,
  ) async {
    try {
      // Format: '2025-04-12'
      final DateTime startOfDay =
          DateTime(date.year, date.month, date.day, 0, 0, 0);
      final DateTime endOfDay =
          DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _supabaseClient
          .from('session')
          .select('timestamp')
          .eq('therapist_id', therapistId)
          .gte('timestamp', startOfDay.toIso8601String())
          .lte('timestamp', endOfDay.toIso8601String());

      final bookedTimestamps =
          (response as List).map((e) => DateTime.parse(e['timestamp'])).toSet();

      // Parse time format "HH:MM AM/PM" or "HH:MM"
      TimeOfDay _parseTime(String timeStr) {
        try {
          final parts = timeStr.trim().split(' ');
          final timeParts = parts[0].split(':');
          int hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          
          if (parts.length > 1) {
            final period = parts[1].toUpperCase();
            if (period == 'PM' && hour != 12) {
              hour += 12;
            } else if (period == 'AM' && hour == 12) {
              hour = 0;
            }
          }
          
          return TimeOfDay(hour: hour, minute: minute);
        } catch (e) {
          // Default to 9 AM if parsing fails
          return const TimeOfDay(hour: 9, minute: 0);
        }
      }

      final startTime = _parseTime(startTimeOfTherapist);
      final endTime = _parseTime(endTimeOfTherapist);
      
      final startHourOfTherapist = startTime.hour;
      final startMinuteOfTherapist = startTime.minute;
      final endHourOfTherapist = endTime.hour;
      final endMinuteOfTherapist = endTime.minute;

      DateTime slotStart = DateTime(date.year, date.month, date.day,
          startHourOfTherapist, startMinuteOfTherapist);
      DateTime slotEnd = DateTime(date.year, date.month, date.day,
          endHourOfTherapist, endMinuteOfTherapist);

      final List<String> availableSlots = [];

      while (slotStart.isBefore(slotEnd)) {
        final isBooked = bookedTimestamps.any((booked) =>
            booked.hour == slotStart.hour && booked.minute == slotStart.minute);

        if (!isBooked) {
          availableSlots.add(_formatTime(slotStart));
        }

        slotStart = slotStart.add(const Duration(minutes: 30));
      }

      return ActionResultSuccess(data: availableSlots, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }


  @override
  Future<ActionResult> bookConsultation(
      ConsultationRequestEntity consultationRequestEntity) async {
    try {
      // Get patient's clinic_id
      final patientResponse = await _supabaseClient
          .from('patient')
          .select('clinic_id, therapist_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (patientResponse == null || patientResponse['clinic_id'] == null) {
        return ActionResultFailure(
          errorMessage: 'Patient is not associated with a clinic',
          statusCode: 400,
        );
      }

      final updateConsultationRequestEntity =
          consultationRequestEntity.copyWith(
        patientId: _supabaseClient.auth.currentUser!.id,
        therapistId: (consultationRequestEntity.therapistId?.isNotEmpty ?? false)
            ? consultationRequestEntity.therapistId
            : (patientResponse['therapist_id'] as String? ?? ''),
        mode: 1,
        status: 'pending',
      );

      // Get the consultation map and add clinic_id
      final consultationMap = updateConsultationRequestEntity.toMap();
      consultationMap['clinic_id'] = patientResponse['clinic_id'];
      
      // Fetch patient's active package if exists
      final packageResponse = await _supabaseClient
          .from('patient_package')
          .select('package_id, id')
          .eq('patient_id', _supabaseClient.auth.currentUser!.id)
          .eq('status', 'active')
          .maybeSingle();
      
      if (packageResponse != null) {
        consultationMap['package_id'] = packageResponse['package_id'];
        consultationMap['patient_package_id'] = packageResponse['id'];
        // Note: therapy_type_id would need to be determined based on the consultation type
        // For now, we'll leave it null for consultations
      }
      
      await _supabaseClient
          .from('session')
          .insert(consultationMap);

      return ActionResultSuccess(
        data: 'Consultation booked successfully', statusCode: 200);
    } catch (e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
  
  @override
  Future<ActionResult> checkIfPatientAssessmentExists() async {
    try {
      final response = await _supabaseClient.from('assessment_results')
          .select('*')
          .eq('patient_id', _supabaseClient.auth.currentUser!.id);

      if(response.isEmpty) {
        return ActionResultSuccess(data: false, statusCode: 200);
      } else {
        return ActionResultSuccess(data: true, statusCode: 200);
      }
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }
  
  @override
  Future<ActionResult> checkIfPatientPackageExists() async {
    try {
      final response = await _supabaseClient.from('patient_package')
          .select('*')
          .eq('patient_id', _supabaseClient.auth.currentUser!.id)
          .eq('status', 'active');
      if(response.isEmpty) {
        return ActionResultSuccess(data: false, statusCode: 200);
      } else {
        return ActionResultSuccess(data: true, statusCode: 200);
      }
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<ActionResult> checkIfPatientConsultationExists() async {
    try {
      final response = await _supabaseClient.from('session')
          .select('*')
          .eq('patient_id', _supabaseClient.auth.currentUser!.id);
      if(response.isEmpty) {
        return ActionResultSuccess(data: false, statusCode: 200);
      } else {
        return ActionResultSuccess(data: true, statusCode: 200);
      }
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

}
