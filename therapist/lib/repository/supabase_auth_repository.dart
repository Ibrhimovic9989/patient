import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:therapist/core/entities/auth_entities/therapist_personal_info_entity.dart';
import 'package:therapist/core/repository/auth/auth_repository.dart';
import 'package:therapist/core/result/action_result.dart';

import '../core/result/result.dart';

class SupabaseAuthRepository implements AuthRepository {

  SupabaseAuthRepository({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ActionResult> signInWithGoogle() async {
    try {
      // Use web view OAuth for both web and mobile
      await _handleOAuthSignIn();
      
      // After successful sign-in, check if the user exists in the therapist table
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return ActionResultFailure(
          errorMessage: 'Failed to get user after sign-in',
          statusCode: 400,
        );
      }
      
      // Query the therapist table to check if user exists
      final therapistData = await _supabaseClient
          .from('therapist')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      final bool isNewUser = therapistData == null;
      
      return ActionResultSuccess(
        data: {
          'id': user.id,
          'email': user.email,
          'name': user.userMetadata?['full_name'] ?? '',
          'is_new_user': isNewUser, // Add this flag
        },
        statusCode: 200,
      );
    } catch (error) {
      return ActionResultFailure(
        errorMessage: 'Sign in failed: $error',
        statusCode: 400,
      );
    }
  }

  Future<void> _handleOAuthSignIn() async {
    // Get current app URL for redirect
    String currentUrl;
    if (kIsWeb) {
      // Use Uri.base for web (works without dart:html)
      currentUrl = Uri.base.toString().split('?').first; // Remove query params
    } else {
      // For mobile, use a deep link URL scheme
      // This should match your app's URL scheme configured in AndroidManifest.xml and Info.plist
      // Supabase will handle the redirect automatically
      currentUrl = 'com.neurotrack.therapist://login-callback';
    }
    
    await _supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: currentUrl,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
  }

  @override
  Future<ActionResult> storePersonalInfo(TherapistPersonalInfoEntity personalInfoEntity) async {
    try {
      // Get the current authenticated user
      final currentUser = _supabaseClient.auth.currentUser;
      
      if (currentUser == null) {
        print("Error: No authenticated user found");
        return ActionResultFailure(
          errorMessage: 'No authenticated user found. Please sign in again.',
          statusCode: 401,
        );
      }
      
      // Build data map directly from entity fields
      // Note: profession_id, profession_name, and license are NOT stored in therapist table
      final data = <String, dynamic>{
        'id': currentUser.id,
        'email': currentUser.email ?? '',  // Required field - get from auth user
        'phone': '',  // Required field - will be empty initially, user can update later
        'name': personalInfoEntity.name,
        'age': personalInfoEntity.age,
        'gender': personalInfoEntity.gender,
        'specialisation': personalInfoEntity.specialization,
        'offered_therapies': personalInfoEntity.therapies,
        'regulatory_body': personalInfoEntity.regulatoryBody,
        'license_number': personalInfoEntity.licenseNumber,
        'start_availability_time': personalInfoEntity.startAvailabilityTime,
        'end_availability_time': personalInfoEntity.endAvailabilityTime,
      };
      
      // Don't remove null values - they're valid for nullable columns
      
      print("Storing therapist data with ID: ${currentUser.id}");
      print("Email: ${currentUser.email}");
      print("Data keys: ${data.keys}");
      
      // Use insert with the complete data including ID, email, and phone
      await _supabaseClient.from('therapist').insert(data);

      return ActionResultSuccess(
        data: 'Personal information stored successfully',
        statusCode: 200
      );
    } catch(e) {
      print("Error storing personal info: $e");
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<ActionResult> updatePersonalInfo(TherapistPersonalInfoEntity personalInfoEntity) async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      
      if (currentUser == null) {
        return ActionResultFailure(
          errorMessage: 'No authenticated user found. Please sign in again.',
          statusCode: 401,
        );
      }
      
      // Build update data map
      final data = <String, dynamic>{
        'name': personalInfoEntity.name,
        'age': personalInfoEntity.age,
        'gender': personalInfoEntity.gender,
        'specialisation': personalInfoEntity.specialization,
        'offered_therapies': personalInfoEntity.therapies,
        'regulatory_body': personalInfoEntity.regulatoryBody,
        'license_number': personalInfoEntity.licenseNumber,
        'start_availability_time': personalInfoEntity.startAvailabilityTime,
        'end_availability_time': personalInfoEntity.endAvailabilityTime,
      };
      
      // Update the therapist record
      await _supabaseClient
          .from('therapist')
          .update(data)
          .eq('id', currentUser.id);

      return ActionResultSuccess(
        data: 'Personal information updated successfully',
        statusCode: 200
      );
    } catch(e) {
      print("Error updating personal info: $e");
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<ActionResult> getPersonalInfo() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      
      if (currentUser == null) {
        return ActionResultFailure(
          errorMessage: 'No authenticated user found. Please sign in again.',
          statusCode: 401,
        );
      }
      
      final response = await _supabaseClient
          .from('therapist')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();
      
      if (response == null) {
        return ActionResultFailure(
          errorMessage: 'Therapist information not found',
          statusCode: 404,
        );
      }
      
      return ActionResultSuccess(
        data: response,
        statusCode: 200,
      );
    } catch(e) {
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

  @override
  Future<String?> getUserId() async {
    try {
      return _supabaseClient.auth.currentUser?.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ActionResult> checkIfUserIsNew(String userId) async {
    try {
      // Query the therapist table to check if user exists
      final therapistData = await _supabaseClient
        .from('therapist')
        .select()
        .eq('id', userId)
        .maybeSingle();
      
      final bool isNewUser = therapistData == null;
      
      return ActionResultSuccess(
        data: {
          'is_new_user': isNewUser,
        },
        statusCode: 200,
      );
    } catch (e) {
      print('Error checking if user is new: $e');
      return ActionResultFailure(
        errorMessage: e.toString(),
        statusCode: 400,
      );
    }
  }

}
