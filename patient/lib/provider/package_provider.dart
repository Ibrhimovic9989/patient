import 'package:flutter/material.dart';
import 'package:patient/core/core.dart';
import 'package:patient/core/repository/repository.dart';
import 'package:patient/repository/supabase_patient_repository.dart';

class PackageProvider with ChangeNotifier {
  final SupabasePatientRepository _repository;

  PackageProvider({required SupabasePatientRepository repository})
      : _repository = repository;

  List<Map<String, dynamic>> _availablePackages = [];
  List<Map<String, dynamic>> get availablePackages => _availablePackages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _activePackage;
  Map<String, dynamic>? get activePackage => _activePackage;

  ApiStatus _assignPackageStatus = ApiStatus.initial;
  ApiStatus get assignPackageStatus => _assignPackageStatus;

  Future<void> fetchAvailablePackages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchClinicPackages();
      if (result is ActionResultSuccess) {
        _availablePackages = List<Map<String, dynamic>>.from(result.data);
        _errorMessage = null;
      } else if (result is ActionResultFailure) {
        _errorMessage = result.errorMessage;
        _availablePackages = [];
      }
    } catch (e) {
      _errorMessage = e.toString();
      _availablePackages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignPackage({
    required String packageId,
    required DateTime startsAt,
  }) async {
    _assignPackageStatus = ApiStatus.initial;
    notifyListeners();

    try {
      final result = await _repository.assignPackageToPatient(
        packageId: packageId,
        startsAt: startsAt,
      );

      if (result is ActionResultSuccess) {
        _assignPackageStatus = ApiStatus.success;
        // Refresh active package
        await getActivePackage();
      } else if (result is ActionResultFailure) {
        _assignPackageStatus = ApiStatus.failure;
        _errorMessage = result.errorMessage;
      }
    } catch (e) {
      _assignPackageStatus = ApiStatus.failure;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> getActivePackage() async {
    try {
      final result = await _repository.getPatientActivePackage();
      if (result is ActionResultSuccess) {
        _activePackage = Map<String, dynamic>.from(result.data);
      } else {
        _activePackage = null;
      }
    } catch (e) {
      _activePackage = null;
    }
    notifyListeners();
  }
}
