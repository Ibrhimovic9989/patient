import 'package:flutter/foundation.dart';
import 'package:patient/core/core.dart';
import 'package:patient/model/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<PatientTaskModel> _allTasks = [];
  Map<String, String> _activityInstructions = {}; // Map of activity_id -> instructions
  DateTime _selectedDate = DateTime.now();
  DateTime? _lastSavedDate; // Track the date for which tasks were last saved
  final PatientRepository _patientRepository;
  ApiStatus _apiStatus = ApiStatus.initial;
  String? _activityId;
  String? _activitySetId;

  TaskProvider({
    required PatientRepository patientRepository,
  }): _patientRepository = patientRepository;

 
  Future<void> getTodayActivities({
    DateTime? date,
  }) async {
    try {
      _apiStatus = ApiStatus.loading;
      notifyListeners();
      final result = await _patientRepository.getTodayActivities(date: date);
      if(result is ActionResultSuccess) {
        _allTasks = result.data.$1;
        _activityId = result.data.$2;
        _activitySetId = result.data.$3;
        _activityInstructions = result.data.$4 as Map<String, String>? ?? {};
        _apiStatus = ApiStatus.success;
        // Update last saved date to the date we just loaded
        if (date != null) {
          _lastSavedDate = DateTime(date.year, date.month, date.day);
        } else {
          _lastSavedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        }
      } else {
        _apiStatus = ApiStatus.failure;
        _allTasks = [];
        _activityId = null;
        _activitySetId = null;
      }
      notifyListeners();
    } catch(e) {
      _apiStatus = ApiStatus.failure;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateActivityCompletion(List<PatientTaskModel> tasks, {DateTime? date}) async {
    try {
      // Only update if we have an activityId and activitySetId
      if (_activityId == null || _activitySetId == null) {
        return;
      }
      
      final result = await _patientRepository.updateActivityCompletion(
        tasks: tasks, 
        activityId: _activityId, 
        activitySetId: _activitySetId,
        date: date ?? _selectedDate,
      );
      if(result is ActionResultSuccess) {
        _apiStatus = ApiStatus.success;
        // Update last saved date
        final saveDate = date ?? _selectedDate;
        _lastSavedDate = DateTime(saveDate.year, saveDate.month, saveDate.day);
      } else {
        _apiStatus = ApiStatus.failure;
      }
    } catch(e) {
      _apiStatus = ApiStatus.failure;
    } finally {
      notifyListeners();
    }
  }

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    final newDate = DateTime(date.year, date.month, date.day);
    final currentDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    
    // If switching to a different date, save current date's tasks first
    if (newDate != currentDate && _allTasks.isNotEmpty && _activityId != null && _activitySetId != null) {
      // Save the current date's tasks before switching
      updateActivityCompletion(_allTasks, date: _selectedDate).then((_) {
        // After saving, load the new date's activities
        _selectedDate = date;
        notifyListeners();
        getTodayActivities(date: date);
      });
    } else {
      // No need to save, just load the new date's activities
      _selectedDate = date;
      notifyListeners();
      getTodayActivities(date: date);
    }
  }

  List<PatientTaskModel> get tasks {
    // Map instructions to tasks if available
    return _allTasks.map((task) {
      if (task.activityId != null && _activityInstructions.containsKey(task.activityId)) {
        return task.copyWith(instructions: _activityInstructions[task.activityId]);
      }
      return task;
    }).toList();
  }

  void toggleTaskCompletion(String activityId, bool isCompleted) async {
    _allTasks = _allTasks.map(
      (task) => task.activityId == activityId ? task.copyWith(isCompleted: isCompleted) : task)
      .toList();
    notifyListeners();
    
    // Auto-save when task completion is toggled
    if (_activityId != null && _activitySetId != null) {
      updateActivityCompletion(_allTasks, date: _selectedDate);
    }
  }

  int get completedTasksCount => tasks.where((task) => task.isCompleted ?? false).length;
  int get totalTasksCount => tasks.length;
  
  String? getInstruction(String activityId) => _activityInstructions[activityId];

  Future<void> saveNote(String activityId, String note) async {
    if (_activityId == null || _activitySetId == null) {
      return;
    }
    
    try {
      final result = await _patientRepository.saveActivityNote(
        activityId: activityId,
        activitySetId: _activitySetId!,
        note: note,
        date: _selectedDate,
      );
      
      if (result is ActionResultSuccess) {
        // Update the task with the note
        _allTasks = _allTasks.map((task) => 
          task.activityId == activityId 
            ? task.copyWith(note: note) 
            : task
        ).toList();
        notifyListeners();
      }
    } catch (e) {
      // Handle error
    }
  }
}
