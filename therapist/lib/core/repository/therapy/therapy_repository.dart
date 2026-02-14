import 'package:therapist/core/core.dart';
import 'package:therapist/core/entities/daily_activity_entities/daily_activity_response.dart';

abstract interface class TherapyRepository {

  /// Get all therapy types
  /// 
  /// Returns a list of therapy types
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful

  Future<ActionResult> getTherapyTypes();

  /// Get therapy types for a patient's active package
  /// 
  /// Returns a list of therapy types that are in the patient's package
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful

  Future<ActionResult> getTherapyTypesForPatient(String patientId);

  /// Add therapy goals
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful

  Future<ActionResult> addTherapyGoals(String therapyTypeId, String goal);

  /// Add therapy observations
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful

  Future<ActionResult> addTherapyObservations(String therapyTypeId, String observation);

  /// Add therapy regressions
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> addTherapyRegressions(String therapyTypeId, String regression);

  /// Add therapy activities
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> addTherapyActivities(String therapyTypeId, String activity);

  /// Get all therapy goals
  /// 
  /// Returns a list of therapy goals
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful

  Future<ActionResult> getAllGoals(String therapyTypeId);

  /// Get all therapy observations
  /// 
  /// Returns a list of therapy observations
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> getAllObservations(String therapyTypeId);

  /// Get all therapy regressions
  /// 
  /// Returns a list of therapy regressions
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> getAllRegressions(String therapyTypeId);

  /// Get all therapy activities
  /// 
  /// Returns a list of therapy activities
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> getAllActivities(String therapyTypeId);

  /// Save therapy goals
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> saveTherapyGoals(TherapyGoalEntity therapyGoalEntity);

  /// Get all daily activities
  /// 
  /// Returns a list of daily activities
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  /// 
  /// [patientId] is the id of the patient
  
  Future<ActionResult> getAllDailyActivities(String patientId);

  /// Add or update daily activity
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> addOrUpdateDailyActivity(DailyActivityResponse dailyActivity);

  /// Delete daily activity
  /// 
  /// Returns a message if the operation is successful
  /// 
  /// Throws an [ActionResultFailure] if an exception occurs
  /// 
  /// Returns an [ActionResultSuccess] if the operation is successful
  
  Future<ActionResult> deleteDailyActivity(String activitySetId);

  /// Get patient progress metrics
  /// 
  /// Returns progress metrics for a specific patient including goals achieved, observations count, regressions count
  /// 
  /// - **Parameters:**
  ///   - `patientId`: The patient ID (required)
  ///   - `startDate`: Optional start date for the range (defaults to 30 days ago)
  ///   - `endDate`: Optional end date for the range (defaults to today)
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with progress metrics data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> getPatientProgressMetrics(
    String patientId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get patient historical trends
  /// 
  /// Returns therapy goals data for a patient grouped by date for chart visualization
  /// 
  /// - **Parameters:**
  ///   - `patientId`: The patient ID (required)
  ///   - `startDate`: Start date for the range (required)
  ///   - `endDate`: End date for the range (required)
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with historical trends data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> getPatientHistoricalTrends(
    String patientId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get existing therapy goal for a specific date and therapy type
  /// 
  /// Returns the therapy goal if it exists
  /// 
  /// - **Parameters:**
  ///   - `patientId`: The patient ID (required)
  ///   - `date`: The date to check (required)
  ///   - `therapyTypeId`: The therapy type ID (required)
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with therapy goal data if found
  ///   - [ActionResultFailure] if not found or error occurs
  Future<ActionResult> getExistingTherapyGoal(
    String patientId, {
    required DateTime date,
    required String therapyTypeId,
  });

  /// Get patient activity completion status
  /// 
  /// Returns activity completion data for a patient including which activities are completed
  /// 
  /// - **Parameters:**
  ///   - `patientId`: The patient ID (required)
  ///   - `activitySetId`: Optional activity set ID to filter by specific set
  ///   - `startDate`: Optional start date for date range
  ///   - `endDate`: Optional end date for date range
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with activity completion data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> getPatientActivityCompletion(
    String patientId, {
    String? activitySetId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Analyze milestones using AI
  /// 
  /// Analyzes therapy goals and daily activities to generate milestone insights
  /// 
  /// - **Parameters:**
  ///   - `patientId`: The patient ID (required)
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with milestone analysis data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> analyzeMilestones(String patientId);
}