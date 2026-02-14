import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapist/core/entities/therapist_entities/therapist_patient_details_entity.dart';
import 'package:therapist/core/entities/therapist_entities/therapist_schedule_entity.dart';
import 'package:therapist/core/entities/therapist_entities/therapist_upcoming_appointment_entity.dart';
import 'package:therapist/core/models/profession_model.dart';
import 'package:therapist/model/therapist_models/therapist_patient_details_model.dart';

import '../core/repository/repository.dart';
import '../core/result/result.dart';

class SupabaseTherapistRepository implements TherapistRepository {

  SupabaseTherapistRepository({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ActionResult> getTherapistSessions() async {
    try {
      // Get therapist's clinic_id
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

      // Get today's date at midnight in UTC
      final now = DateTime.now().toUtc();
      final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final response = await _supabaseClient.from('session')
      .select('*, patient(patient_name, phone)')
      .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
      .eq('clinic_id', clinicId) // Filter by clinic
      .eq('is_consultation', false)
      .gte('timestamp', todayStart)
      .lte('timestamp', todayEnd);

      if(response.isEmpty) {
        return ActionResultSuccess(data: <dynamic>[], statusCode: 200);
      } else {
        final data = response.map((sessionData) {
          final patientData = sessionData['patient'] as Map<String, dynamic>?;
          final flattenedData = {
            ...sessionData,
            'patient_name': patientData?['patient_name'],
            'phone': patientData?['phone'],
          };
          return TherapistScheduleEntityMapper.fromMap(flattenedData).toModel();
        }).toList();

        return ActionResultSuccess(data: data, statusCode: 200); 
      } 
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }

  @override
  Future<ActionResult> changeAppointmentStatus(String appointmentId, String status) async {
    try {
      await _supabaseClient.from('session')
      .update({'status': status})
      .eq('id', appointmentId);
  
     return ActionResultSuccess(data: 'Appointment Update Successfully', statusCode: 200);
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }

  @override
  Future<ActionResult> getTherapistPatients() async {
   try {
      final therapistId = _supabaseClient.auth.currentUser!.id;
      
      // Get therapist's clinic_id
      final therapistResponse = await _supabaseClient
          .from('therapist')
          .select('clinic_id')
          .eq('id', therapistId)
          .maybeSingle();

      if (therapistResponse == null || therapistResponse['clinic_id'] == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist not assigned to a clinic',
          statusCode: 404,
        );
      }

      final clinicId = therapistResponse['clinic_id'];

      // Get patients where this therapist is assigned to at least one therapy type
      final assignmentsResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('patient_id, therapy_type_id, patient:patient_id(*), therapy:therapy_type_id(name)')
          .eq('therapist_id', therapistId)
          .eq('is_active', true);

      if (assignmentsResponse.isEmpty) {
        return ActionResultSuccess(data: <TherapistPatientDetailsEntity>[], statusCode: 200);
      }

      // Group by patient and collect therapy types
      final Map<String, List<String>> patientTherapyTypes = {};
      final Map<String, Map<String, dynamic>> patientDataMap = {};

      for (final assignment in assignmentsResponse) {
        final patient = assignment['patient'] as Map<String, dynamic>?;
        final therapy = assignment['therapy'] as Map<String, dynamic>?;
        
        if (patient != null) {
          final patientId = patient['id'] as String;
          final therapyName = therapy?['name'] as String?;
          
          // Only include patients from the same clinic
          if (patient['clinic_id'] == clinicId) {
            if (therapyName != null) {
              patientTherapyTypes.putIfAbsent(patientId, () => []).add(therapyName);
            }
            
            if (!patientDataMap.containsKey(patientId)) {
              patientDataMap[patientId] = patient;
            }
          }
        }
      }

      // Fetch active packages for these patients
      final patientIds = patientDataMap.keys.toList();
      
      Map<String, Map<String, dynamic>> packageMap = {};
      List<String> therapyTypesList = [];
      
      if (patientIds.isNotEmpty) {
        // Fetch active patient packages with session usage
        // Fetch all active packages and filter by patient_id in Dart
        final allPackagesResponse = await _supabaseClient
            .from('patient_package')
            .select('''
              id,
              patient_id,
              package_id,
              status,
              expires_at,
              sessions_used,
              package:package_id(
                id,
                name,
                package_therapy_details(
                  therapy_type_id,
                  session_count,
                  therapy:therapy_type_id(name)
                )
              )
            ''')
            .eq('status', 'active');
        
        // Filter packages by patient_ids
        final packagesResponse = (allPackagesResponse as List)
            .where((pkg) => patientIds.contains(pkg['patient_id'] as String))
            .toList();
        
        // Build package map by patient_id with therapy types and session usage
        for (final pkg in packagesResponse) {
          final patientId = pkg['patient_id'] as String;
          final package = pkg['package'] as Map<String, dynamic>?;
          final packageTherapyDetails = package?['package_therapy_details'] as List?;
          
          // Extract therapy type names and session usage
          final therapyTypes = <String>[];
          final sessionUsage = <String, Map<String, int>>{}; // therapy_type_id -> {used, total}
          
          if (packageTherapyDetails != null) {
            for (final detail in packageTherapyDetails) {
              final therapy = detail['therapy'] as Map<String, dynamic>?;
              if (therapy != null && therapy['name'] != null) {
                therapyTypes.add(therapy['name'] as String);
                
                final therapyTypeId = detail['therapy_type_id'] as String;
                final sessionCount = detail['session_count'] as int? ?? 0;
                final sessionsUsed = (pkg['sessions_used'] as Map<String, dynamic>?)?[therapyTypeId] as int? ?? 0;
                
                sessionUsage[therapyTypeId] = {
                  'used': sessionsUsed,
                  'total': sessionCount,
                };
              }
            }
          }
          
          packageMap[patientId] = {
            'package_name': package?['name'],
            'package_id': package?['id'],
            'package_expires_at': pkg['expires_at'],
            'package_status': pkg['status'],
            'package_therapy_types': therapyTypes,
            'session_usage': sessionUsage,
          };
        }
      }
    
      // Transform the response to include package information and therapy types from assignments
      final data = patientDataMap.values.map((patientData) {
        final patientId = patientData['id'] as String;
        final packageInfo = packageMap[patientId];
        final therapyTypes = patientTherapyTypes[patientId] ?? [];
        
        if (packageInfo != null) {
          patientData['package_name'] = packageInfo['package_name'];
          patientData['package_id'] = packageInfo['package_id'];
          patientData['package_expires_at'] = packageInfo['package_expires_at'];
          patientData['package_status'] = packageInfo['package_status'];
          patientData['package_therapy_types'] = therapyTypes; // Use assigned therapy types
          patientData['session_usage'] = packageInfo['session_usage'];
        } else {
          // Even without package, include therapy types from assignments
          patientData['package_therapy_types'] = therapyTypes;
        }
        
        return TherapistPatientDetailsEntityMapper.fromMap(patientData);
      }).toList();

      return ActionResultSuccess(data: data, statusCode: 200); 
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
   } 
  }

  @override
  Future<ActionResult> getTherapistSchedule() async {
   try {
      // Get therapist's clinic_id
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

      final response = await _supabaseClient.from('session')
      .select('*')
      .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
      .eq('clinic_id', clinicId); // Filter by clinic
    
      final data = response.map((data) => TherapistScheduleEntityMapper.fromMap(data)).toList();

      return ActionResultSuccess(data: data, statusCode: 200); 
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
   }
  }

  @override
  Future<ActionResult> getTherapistUpcomingAppointments() async {
    try {
      // Get therapist's clinic_id
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

      final response = await _supabaseClient.from('session')
      .select('*')
      .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
      .eq('clinic_id', clinicId) // Filter by clinic
      .eq('status', 'pending'); // Use lowercase
    
      final data = response.map((data) => TherapistUpcomingAppointmentEntityMapper.fromMap(data)).toList();

      return ActionResultSuccess(data: data, statusCode: 200); 
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }
  
  @override
  Future<ActionResult> getAllSessionsWithPatientDetails() async {
    try {
      // Get therapist's clinic_id
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

      final response = await _supabaseClient.from('session')
        .select('*, patient(patient_name, phone)')
        .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
        .eq('clinic_id', clinicId); // Filter by clinic

      if(response.isEmpty) {
        return ActionResultSuccess(data: <dynamic>[], statusCode: 200);
      } else {
        final data = response.map((data) => TherapistScheduleEntityMapper.fromMap(data).toModel()).toList();
        return ActionResultSuccess(data: data, statusCode: 200);
      }
    } catch(e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }

  @override
  Future<ActionResult> getTotalPatients() async {
    try {
      final therapistId = _supabaseClient.auth.currentUser!.id;
      
      // Get therapist's clinic_id
      final therapistResponse = await _supabaseClient
          .from('therapist')
          .select('clinic_id')
          .eq('id', therapistId)
          .maybeSingle();

      if (therapistResponse == null || therapistResponse['clinic_id'] == null) {
        return ActionResultSuccess(data: 0, statusCode: 200);
      }

      final clinicId = therapistResponse['clinic_id'];

      // Count distinct patients from patient_therapist_assignment table
      // This ensures we count all patients assigned to this therapist for any therapy type
      final assignmentsResponse = await _supabaseClient
          .from('patient_therapist_assignment')
          .select('patient_id, patient:patient_id(clinic_id)')
          .eq('therapist_id', therapistId)
          .eq('is_active', true);

      if (assignmentsResponse.isEmpty) {
        return ActionResultSuccess(data: 0, statusCode: 200);
      }

      // Get unique patient IDs that belong to the same clinic
      final uniquePatientIds = <String>{};
      for (final assignment in assignmentsResponse) {
        final patient = assignment['patient'] as Map<String, dynamic>?;
        if (patient != null && patient['clinic_id'] == clinicId) {
          final patientId = assignment['patient_id'] as String;
          uniquePatientIds.add(patientId);
        }
      }

      final count = uniquePatientIds.length;
      return ActionResultSuccess(data: count, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }
  
  @override
  Future<ActionResult> getTotalSessions() async {
    try {
      // Get therapist's clinic_id
      final therapistResponse = await _supabaseClient
          .from('therapist')
          .select('clinic_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (therapistResponse == null || therapistResponse['clinic_id'] == null) {
        return ActionResultSuccess(data: 0, statusCode: 200);
      }

      final clinicId = therapistResponse['clinic_id'];

      final response = await _supabaseClient
          .from('session')
          .select('id')
          .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
          .eq('clinic_id', clinicId);

      final count = response.length;
      return ActionResultSuccess(data: count, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }
  
  @override
  Future<ActionResult> getTotalTherapies() async {
    try {
      // Get therapist's clinic_id
      final therapistResponse = await _supabaseClient
          .from('therapist')
          .select('clinic_id')
          .eq('id', _supabaseClient.auth.currentUser!.id)
          .maybeSingle();

      if (therapistResponse == null || therapistResponse['clinic_id'] == null) {
        return ActionResultSuccess(data: 0, statusCode: 200);
      }

      final clinicId = therapistResponse['clinic_id'];

      // Count distinct therapy types (therapy_type_id) for this therapist
      final response = await _supabaseClient
          .from('therapy_goal')
          .select('therapy_type_id')
          .eq('therapist_id', _supabaseClient.auth.currentUser!.id)
          .eq('clinic_id', clinicId)
          .not('therapy_type_id', 'is', null);

      // Get distinct therapy type IDs
      final distinctTherapyTypes = <String>{};
      for (final goal in response) {
        final therapyTypeId = goal['therapy_type_id'] as String?;
        if (therapyTypeId != null) {
          distinctTherapyTypes.add(therapyTypeId);
        }
      }

      final count = distinctTherapyTypes.length;
      return ActionResultSuccess(data: count, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }

  @override
  Future<ActionResult> fetchProfessions() async {
    try {
      final response = await _supabaseClient.from('profession').select('*');
      
      final data = response.map((item) => ProfessionModel.fromMap(item)).toList();
      
      return ActionResultSuccess(data: data, statusCode: 200);
    } catch (e) {
      return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
    }
  }
@override
Future<ActionResult> fetchRegulatoryBodies(int professionId) async {
  try {
    final response = await _supabaseClient
        .from('profession_details')
        .select('id, profession_id, regulatory_body')
        .eq('profession_id', professionId)
        .not('regulatory_body', 'is', null); // Only get non-null values
    
    // Transform data after retrieving it
    final Set<String> uniqueBodies = {};
    List<RegulatoryBodyModel> data = [];
    int counter = 1;
    
    for (var item in response) {
      final body = item['regulatory_body'] as String?;
      if (body != null && !uniqueBodies.contains(body)) {
        uniqueBodies.add(body);
        data.add(RegulatoryBodyModel.fromMap({
          'id': counter++, // Use counter instead of UUID
          'profession_id': item['profession_id'] as int,
          'name': body,
        }));
      }
    }
    
    return ActionResultSuccess(data: data, statusCode: 200);
  } catch (e) {
    print('Error fetching regulatory bodies: $e');
    return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
  }
}

@override
Future<ActionResult> fetchSpecializations(int professionId) async {
  try {
    final response = await _supabaseClient
        .from('profession_details')
        .select('id, profession_id, specialization')
        .eq('profession_id', professionId)
        .not('specialization', 'is', null); // Only get non-null values
    
    // Transform data after retrieving it
    final Set<String> uniqueSpecs = {};
    List<SpecializationModel> data = [];
    int counter = 1;
    
    for (var item in response) {
      final spec = item['specialization'] as String?;
      if (spec != null && !uniqueSpecs.contains(spec)) {
        uniqueSpecs.add(spec);
        data.add(SpecializationModel.fromMap({
          'id': counter++, // Use counter instead of UUID
          'profession_id': item['profession_id'] as int,
          'name': spec,
        }));
      }
    }
    
    return ActionResultSuccess(data: data, statusCode: 200);
  } catch (e) {
    print('Error fetching specializations: $e');
    return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
  }
}

@override
Future<ActionResult> fetchTherapies(int professionId) async {
  try {
    final response = await _supabaseClient
        .from('profession_details')
        .select('id, profession_id, therapy_offered')
        .eq('profession_id', professionId)
        .not('therapy_offered', 'is', null); // Only get non-null values
    
    // Transform data after retrieving it
    final Set<String> uniqueTherapies = {};
    List<TherapyModel> data = [];
    int counter = 1;
    
    for (var item in response) {
      final therapy = item['therapy_offered'] as String?;
      if (therapy != null && !uniqueTherapies.contains(therapy)) {
        uniqueTherapies.add(therapy);
        data.add(TherapyModel.fromMap({
          'id': counter++, // Use counter instead of UUID
          'profession_id': item['profession_id'] as int,
          'name': therapy,
        }));
      }
    }
    
    return ActionResultSuccess(data: data, statusCode: 200);
  } catch (e) {
    print('Error fetching therapies: $e');
    return ActionResultFailure(errorMessage: e.toString(), statusCode: 400);
  }
}

@override
Future<ActionResult> fetchPatientsMappedToTherapist() async {
  try {
    final therapistId = _supabaseClient.auth.currentUser!.id;
    
    // First get therapist's clinic_id
    final therapistResponse = await _supabaseClient
        .from('therapist')
        .select('clinic_id')
        .eq('id', therapistId)
        .maybeSingle();

    if (therapistResponse == null || therapistResponse['clinic_id'] == null) {
      return ActionResultFailure(
        errorMessage: 'Therapist not assigned to a clinic',
        statusCode: 404,
      );
    }

    final clinicId = therapistResponse['clinic_id'];

    // Get patients where this therapist is assigned to at least one therapy type
    final assignmentsResponse = await _supabaseClient
        .from('patient_therapist_assignment')
        .select('patient_id, therapy_type_id, patient:patient_id(id, patient_name, phone, email, clinic_id), therapy:therapy_type_id(name)')
        .eq('therapist_id', therapistId)
        .eq('is_active', true);

    if (assignmentsResponse.isEmpty) {
      return ActionResultSuccess(data: <TherapistPatientDetailsModel>[], statusCode: 200);
    }

    // Group by patient and collect therapy types
    final Map<String, List<String>> patientTherapyTypes = {};
    final Map<String, Map<String, dynamic>> patientDataMap = {};

    for (final assignment in assignmentsResponse) {
      final patient = assignment['patient'] as Map<String, dynamic>?;
      final therapy = assignment['therapy'] as Map<String, dynamic>?;
      
      if (patient != null) {
        final patientId = patient['id'] as String;
        final therapyName = therapy?['name'] as String?;
        
        // Only include patients from the same clinic
        if (patient['clinic_id'] == clinicId) {
          if (therapyName != null) {
            patientTherapyTypes.putIfAbsent(patientId, () => []).add(therapyName);
          }
          
          if (!patientDataMap.containsKey(patientId)) {
            patientDataMap[patientId] = patient;
          }
        }
      }
    }

    // Fetch active packages for these patients
    final patientIds = patientDataMap.keys.toList();
    
    Map<String, Map<String, dynamic>> packageMap = {};
    
    if (patientIds.isNotEmpty) {
      // Fetch active patient packages with session usage
      final allPackagesResponse = await _supabaseClient
          .from('patient_package')
          .select('''
            id,
            patient_id,
            package_id,
            status,
            expires_at,
            sessions_used,
            package:package_id(
              id,
              name,
              package_therapy_details(
                therapy_type_id,
                session_count,
                therapy:therapy_type_id(name)
              )
            )
          ''')
          .eq('status', 'active');
      
      // Filter packages by patient_ids
      final packagesResponse = (allPackagesResponse as List)
          .where((pkg) => patientIds.contains(pkg['patient_id'] as String))
          .toList();
      
      // Build package map by patient_id with therapy types and session usage
      for (final pkg in packagesResponse) {
        final patientId = pkg['patient_id'] as String;
        final package = pkg['package'] as Map<String, dynamic>?;
        final packageTherapyDetails = package?['package_therapy_details'] as List?;
        
        // Extract therapy type names and session usage
        final therapyTypes = <String>[];
        final sessionUsage = <String, Map<String, int>>{}; // therapy_type_id -> {used, total}
        
        if (packageTherapyDetails != null) {
          for (final detail in packageTherapyDetails) {
            final therapy = detail['therapy'] as Map<String, dynamic>?;
            if (therapy != null && therapy['name'] != null) {
              therapyTypes.add(therapy['name'] as String);
              
              final therapyTypeId = detail['therapy_type_id'] as String;
              final sessionCount = detail['session_count'] as int? ?? 0;
              final sessionsUsed = (pkg['sessions_used'] as Map<String, dynamic>?)?[therapyTypeId] as int? ?? 0;
              
              sessionUsage[therapyTypeId] = {
                'used': sessionsUsed,
                'total': sessionCount,
              };
            }
          }
        }
        
        packageMap[patientId] = {
          'package_name': package?['name'],
          'package_id': package?['id'],
          'package_expires_at': pkg['expires_at'],
          'package_status': pkg['status'],
          'package_therapy_types': therapyTypes,
          'session_usage': sessionUsage,
        };
      }
    }

    // Transform the response to include package information and therapy types from assignments
    final data = patientDataMap.values.map((patientData) {
      final patientId = patientData['id'] as String;
      final packageInfo = packageMap[patientId];
      final therapyTypes = patientTherapyTypes[patientId] ?? [];
      
      return TherapistPatientDetailsModel(
        patientId: patientId,
        patientName: patientData['patient_name'] ?? '',
        phoneNo: patientData['phone'] ?? '',
        email: patientData['email'] ?? '',
        packageName: packageInfo?['package_name'],
        packageStatus: packageInfo?['package_status'],
        packageExpiresAt: packageInfo != null && packageInfo['package_expires_at'] != null 
            ? DateTime.parse(packageInfo['package_expires_at'] as String)
            : null,
        packageTherapyTypes: therapyTypes,
        sessionUsage: packageInfo?['session_usage'],
      );
    }).toList();

    return ActionResultSuccess(data: data, statusCode: 200);
  } catch (e) {
    return ActionResultFailure(errorMessage: e.toString(), statusCode: 500);
  }
}
}