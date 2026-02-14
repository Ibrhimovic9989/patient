import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:patient/core/repository/auth/auth.dart';
import 'package:patient/core/utils/utils.dart';
import 'package:patient/model/auth_models/auth_model.dart';
import 'package:patient/model/auth_models/personal_info_model.dart';
import 'package:patient/model/auth_models/therapist_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/result/result.dart';


enum AuthNavigationStatus {
  unknown,
  clinicSelection,
  home,
  personalDetails,
  assessment,
  packageSelection,
  initialConsultation,
  error,
}
extension AuthNavigationStatusX on AuthNavigationStatus {
  bool get isUnknown => this == AuthNavigationStatus.unknown;
  bool get isClinicSelection => this == AuthNavigationStatus.clinicSelection;
  bool get isHome => this == AuthNavigationStatus.home;
  bool get isPersonalDetails => this == AuthNavigationStatus.personalDetails;
  bool get isAssessment => this == AuthNavigationStatus.assessment;
  bool get isPackageSelection => this == AuthNavigationStatus.packageSelection;
  bool get isInitialConsultation => this == AuthNavigationStatus.initialConsultation;
  bool get isError => this == AuthNavigationStatus.error;
}

class AuthProvider extends ChangeNotifier {

  AuthProvider({
    required AuthRepository authRepository,
  }): _authRepository = authRepository;

  final AuthRepository _authRepository;

  ApiStatus _apiStatus = ApiStatus.initial;
  ApiStatus get apiStatus => _apiStatus;
  
  String _apiErrorMessage = '';
  String get apiErrorMessage => _apiErrorMessage;

  final supabase = Supabase.instance.client;

  AuthNavigationStatus _authNavigationStatus = AuthNavigationStatus.unknown;
  AuthNavigationStatus get authNavigationStatus => _authNavigationStatus;

  List<TherapistModel> _therapistList = [];
  List<TherapistModel> get therapistList => _therapistList;
  set therapistList(List<TherapistModel> value) {
    _therapistList = value;
    notifyListeners();
  }

  List<String> _availableBookingSlots = [];
  List<String> get availableBookingSlots => _availableBookingSlots;
  set availableBookingSlots(List<String> value) {
    _availableBookingSlots = value;
    notifyListeners();
  }
  ApiStatus _availableBookingSlotsStatus = ApiStatus.initial;
  ApiStatus get availableBookingSlotsStatus => _availableBookingSlotsStatus;

  ApiStatus _bookConsulationStatus = ApiStatus.initial; 
  ApiStatus get bookConsulationStatus => _bookConsulationStatus;

  Future<void> signInWithGoogle() async {
    try {
      // Use web view OAuth for both web and mobile
      await _handleOAuthSignIn();
    } catch (error) {
      throw Exception('Sign in failed: $error');
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
      currentUrl = 'com.neurotrack.patient://login-callback';
    }
    
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: currentUrl,
      authScreenLaunchMode: LaunchMode.platformDefault,
    );
  }

  String? getFullName() {
    final session = supabase.auth.currentSession;
    if (session == null) return null;
    return session.user.userMetadata?['full_name'] ?? 'User';
  }

  Future<void> checkIfPatientExists() async {
    _authNavigationStatus = AuthNavigationStatus.unknown;
    notifyListeners();

    // Step 1: Check if patient exists (onboarding)
    final result = await _authRepository.checkIfPatientExists();
    if (result is! ActionResultSuccess) {
      _setStatus(AuthNavigationStatus.error);
      return;
    }

    final bool patientExists = result.data as bool;
    if (!patientExists) {
      // New patient - must complete onboarding first
      _setStatus(AuthNavigationStatus.personalDetails);
      return;
    }

    // Step 2: Check if patient has a clinic assigned (REQUIRED)
    final clinicCheckResult = await _checkIfPatientHasClinic();
    if (clinicCheckResult == false) {
      // Patient doesn't have a clinic, must select one
      _setStatus(AuthNavigationStatus.clinicSelection);
      return;
    }

    // Step 3: Check if patient has a package assigned (REQUIRED)
    final packageResult = await _authRepository.checkIfPatientPackageExists();
    if (packageResult is! ActionResultSuccess) {
      _setStatus(AuthNavigationStatus.error);
      return;
    }

    final bool packageExists = packageResult.data as bool;
    if (!packageExists) {
      // Patient must select a package
      _setStatus(AuthNavigationStatus.packageSelection);
      return;
    }

    // Step 4: Assessment is OPTIONAL - check but don't block
    final assessmentResult =
        await _authRepository.checkIfPatientAssessmentExists();
    if (assessmentResult is! ActionResultSuccess) {
      // If assessment check fails, continue to main app
      _setStatus(AuthNavigationStatus.home);
      return;
    }

    final bool assessmentExists = assessmentResult.data as bool;
    if (!assessmentExists) {
      // Assessment is optional - show it but allow skipping
      // For now, we'll go to home, but assessment screen should allow skipping
      _setStatus(AuthNavigationStatus.assessment);
      return;
    }

    // All required steps completed - go to main app
    _setStatus(AuthNavigationStatus.home);
  }

  /// Check if the current patient has a clinic assigned
  Future<bool> _checkIfPatientHasClinic() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await supabase
          .from('patient')
          .select('clinic_id')
          .eq('id', userId)
          .maybeSingle();

      return response != null && response['clinic_id'] != null;
    } catch (e) {
      // If error, assume no clinic (safer to show selection screen)
      return false;
    }
  }

  void _setStatus(AuthNavigationStatus status) {
    _authNavigationStatus = status;
    notifyListeners();
  }


  void storePatientPersonalInfo(PersonalInfoModel personalInfoModel) async {
    _apiStatus = ApiStatus.initial;
    _apiErrorMessage = '';
    notifyListeners();
    final ActionResult result = await _authRepository.storePersonalInfo(personalInfoModel.toEntity());
    if(result is ActionResultSuccess) {
      _apiStatus = ApiStatus.success;
    } else {
      _apiStatus = ApiStatus.failure;
      _apiErrorMessage = result.errorMessage ?? 'An error occurred. Please try again.';
    }
    notifyListeners();
  }

  void getAllTherapist() async {
    _apiStatus = ApiStatus.initial;
    _apiErrorMessage = '';
    notifyListeners();
    final ActionResult result = await _authRepository.getAllAvailableTherapist();
    if(result is ActionResultSuccess) {
      therapistList = result.data as List<TherapistModel>;
      _apiStatus = ApiStatus.success;
      notifyListeners();
    } else {
      _apiStatus = ApiStatus.failure;
      _apiErrorMessage = result.errorMessage ?? 'An error occurred. Please try again.';
      notifyListeners();
    }
  }

  void getAvailableBookingSlotsForTherapist(
    String therapistId,
    DateTime date) async {
    _availableBookingSlotsStatus = ApiStatus.initial;
    _availableBookingSlots = [];
    notifyListeners();
    final therapistData = therapistList.firstWhere((element) => element.id == therapistId);
    
    // Handle nullable availability times
    final startTime = therapistData.startAvailabilityTime ?? '09:00';
    final endTime = therapistData.endAvailabilityTime ?? '17:00';
    
    final ActionResult result = await _authRepository.getAvailableBookingSlotsForTherapist(
      therapistId,
      date,
      startTime,
      endTime,
    );
      if(result is ActionResultSuccess) {
        _availableBookingSlots = result.data as List<String>;
        _availableBookingSlotsStatus = ApiStatus.success;
        notifyListeners();
      } else {
        _availableBookingSlotsStatus = ApiStatus.failure;
        notifyListeners();
      }
  }

  void bookConsultation(String therapistId, DateTime date, int index) async  {
    final consultationModel = ConsultationRequestModel(
      timestamp: _updateTime(date, availableBookingSlots[index]),
      therapistId: therapistId,
      isConsultation: true,
      duration: 30,
      name: 'Consultation Session with the Therapist'
    );

    _bookConsulationStatus = ApiStatus.initial;

    notifyListeners();

    final ActionResult result = await _authRepository.bookConsultation(consultationModel.toEntity());

    if(result is ActionResultSuccess) {
      _bookConsulationStatus = ApiStatus.success;
      notifyListeners();
    } else {
      _bookConsulationStatus = ApiStatus.failure;
      notifyListeners();
    }
  }

 DateTime _updateTime(DateTime date, String timeStr) {
    final timeParts = timeStr.split(' ');
    final time = timeParts[0];
    final period = timeParts[1].toUpperCase();

    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void resetNavigationStatus() {
    _authNavigationStatus = AuthNavigationStatus.unknown;
    notifyListeners();
  }

  void resetBookingSlots() {
    _availableBookingSlots = [];
    notifyListeners();
  }

  void resetApiStatus() {
    _apiStatus = ApiStatus.initial;
    _apiErrorMessage = '';
    notifyListeners();
  }
}
