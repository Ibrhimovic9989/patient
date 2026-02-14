import 'package:patient/core/entities/patient_entities/patient_schedule_appointment_entity.dart';
import 'package:patient/core/result/result.dart';

import '../../../model/task_model.dart';

abstract interface class PatientRepository {

  /// Schedules an appointment by inserting a new record into the `session` table.
  ///
  /// This method takes a [PatientScheduleAppointmentEntity] object, converts it to a map,
  /// and inserts it into the `session` table using Supabase.
  ///
  /// - **Parameters:**  
  ///   - `appointmentEntity` : An instance of [PatientScheduleAppointmentEntity]  
  ///     containing appointment details.
  ///
  /// - **Returns:**  
  ///   - A [Future] of [ActionResult], which can either be:  
  ///     - [ActionResultSuccess] with a success message and status code `200` if the appointment  
  ///       is successfully scheduled.  
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  ///
  /// - **Exceptions:**  
  ///   - If an error occurs while inserting the record, it is caught and returned as a failure.
  
  Future<ActionResult> scheduleAppointment(PatientScheduleAppointmentEntity appointmentEntity);

  Future<ActionResult> getTherapyGoals({
    required DateTime date,
    String? therapyTypeId,
  });
  
  Future<ActionResult> getTherapyTypesForPackage();
  
  Future<ActionResult> getAppointmentsForDate(DateTime date);
  /// Fetches all appointments from the `session` table.
  ///
  /// This method fetches all appointments from the `session` table using Supabase.
  ///
  /// - **Returns:**
  ///   - A [Future] of [ActionResult], which can either be:
  ///     - [ActionResultSuccess] with a success message and status code `200` if the appointments are successfully fetched.
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  ///
  /// - **Exceptions:**
  ///   - If an error occurs while fetching the appointments, it is caught and returned as a failure.
  Future<ActionResult> fetchAllAppointments();

  /// Deletes an appointment from the `session` table.
  ///
  /// This method deletes an appointment from the `session` table using Supabase.
  ///
  /// - **Parameters:**
  ///   - `id` : The ID of the appointment to be deleted.
  ///
  /// - **Returns:**
  ///   - A [Future] of [ActionResult], which can either be:
  ///     - [ActionResultSuccess] with a success message and status code `200` if the appointment is successfully deleted.
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  ///
  /// - **Exceptions:**
  ///   - If an error occurs while deleting the appointment, it is caught and returned as a failure.
  Future<ActionResult> deleteAppointment(String id);

  /// Fetches the activities for the given date.
  ///
  /// This method fetches the activities for the given date from the `daily_activity` table using Supabase.
  ///
  /// - **Parameters:**
  ///   - `date` : The date for which the activities are to be fetched.
  ///
  /// - **Returns:**
  ///   - A [Future] of [ActionResult], which can either be:
  ///     - [ActionResultSuccess] with a success message and status code `200` if the activities are successfully fetched.
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  ///
  /// - **Exceptions:**
  ///   - If an error occurs while fetching the activities, it is caught and returned as a failure.
  Future<ActionResult> getTodayActivities({
    DateTime? date
  });

  /// Updates the completion status of the activities.
  ///
  /// This method updates the completion status of the activities in the `daily_activity` table using Supabase.
  ///
  /// - **Parameters:**
  ///   - `tasks` : A list of [PatientTaskModel] objects containing the activities to be updated.
  ///   - `activityId` : The ID of the activity log entry to update.
  ///   - `activitySetId` : The ID of the activity set.
  ///   - `date` : The date for which the activities are being updated (optional, defaults to today).

  /// - **Returns:**
  ///   - A [Future] of [ActionResult], which can either be:
  ///     - [ActionResultSuccess] with a success message and status code `200` if the activities are successfully updated.
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  ///
  /// - **Exceptions:**
  ///   - If an error occurs while updating the activities, it is caught and returned as a failure.
  Future<ActionResult> updateActivityCompletion({
    required List<PatientTaskModel> tasks,
    String? activityId,
    String? activitySetId,
    DateTime? date,
  });

  /// Saves a note for a specific activity.
  ///
  /// This method saves a parent note for a specific activity in the daily_activity_logs table.
  ///
  /// - **Parameters:**
  ///   - `activityId`: The ID of the activity item.
  ///   - `activitySetId`: The ID of the activity set.
  ///   - `note`: The note text to save.
  ///   - `date`: The date for which the note is being saved.
  ///
  /// - **Returns:**
  ///   - A [Future] of [ActionResult], which can either be:
  ///     - [ActionResultSuccess] with a success message and status code `200` if the note is successfully saved.
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  Future<ActionResult> saveActivityNote({
    required String activityId,
    required String activitySetId,
    required String note,
    required DateTime date,
  });

  /// Fetches the reports for the given date.
  ///
  /// This method fetches the reports for the given date from the `daily_activity` table using Supabase.
  ///
  /// - **Parameters:**
  ///   - `date` : The date for which the reports are to be fetched.
  ///
  /// - **Returns:**
  ///   - A [Future] of [ActionResult], which can either be:
  ///     - [ActionResultSuccess] with a success message and status code `200` if the reports are successfully fetched.
  ///     - [ActionResultFailure] with an error message and status code `500` if an exception occurs.
  ///
  /// - **Exceptions:**
  ///   - If an error occurs while fetching the reports, it is caught and returned as a failure.

  Future<ActionResult> getReports({
    required DateTime date,
  });

  /// Get progress metrics for a date range
  /// 
  /// Returns progress metrics including goals achieved, observations count, regressions count, attendance rate
  /// 
  /// - **Parameters:**
  ///   - `startDate`: Optional start date for the range (defaults to 30 days ago)
  ///   - `endDate`: Optional end date for the range (defaults to today)
  ///   - `therapyTypeId`: Optional therapy type filter
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with progress metrics data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> getProgressMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? therapyTypeId,
  });

  /// Get historical trends for therapy goals
  /// 
  /// Returns therapy goals data grouped by date for chart visualization
  /// 
  /// - **Parameters:**
  ///   - `startDate`: Start date for the range (required)
  ///   - `endDate`: End date for the range (required)
  ///   - `therapyTypeId`: Optional therapy type filter
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with historical trends data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> getHistoricalTrends({
    required DateTime startDate,
    required DateTime endDate,
    String? therapyTypeId,
  });

  /// Analyze milestones using AI
  /// 
  /// Analyzes therapy goals and daily activities to generate milestone insights
  /// 
  /// - **Returns:**
  ///   - [ActionResultSuccess] with milestone analysis data
  ///   - [ActionResultFailure] if an error occurs
  Future<ActionResult> analyzeMilestones();
 
}