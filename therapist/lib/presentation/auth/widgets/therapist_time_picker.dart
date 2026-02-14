
import 'package:flutter/material.dart';

class TherapistTimePicker extends StatefulWidget {
  final Function(TimeOfDay start, TimeOfDay end) onTimeSelected;
  final String? initialStartTime;
  final String? initialEndTime;

  const TherapistTimePicker({
    super.key,
    required this.onTimeSelected,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  _TherapistTimePickerState createState() => _TherapistTimePickerState();
}

class _TherapistTimePickerState extends State<TherapistTimePicker> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? errorText;

  @override
  void initState() {
    super.initState();
    // Parse initial times if provided (format: "HH:MM AM/PM")
    if (widget.initialStartTime != null) {
      startTime = _parseTimeString(widget.initialStartTime!);
    }
    if (widget.initialEndTime != null) {
      endTime = _parseTimeString(widget.initialEndTime!);
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Format: "HH:MM AM" or "HH:MM PM"
      final parts = timeStr.split(' ');
      if (parts.length != 2) return null;
      
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase();
      
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay initialTime = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (startTime ?? initialTime) : (endTime ?? initialTime),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }

        if (startTime != null && endTime != null) {
          final startMinutes = startTime!.hour * 60 + startTime!.minute;
          final endMinutes = endTime!.hour * 60 + endTime!.minute;

          if (endMinutes <= startMinutes) {
            setState(() {
              errorText = "End time must be after start time.";
            });
          } else {
            errorText = null;
            widget.onTimeSelected(startTime!, endTime!);
          }
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Select";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Time", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(true),
                child: _TimeBox(label: "Start Time", value: _formatTime(startTime)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(false),
                child: _TimeBox(label: "End Time", value: _formatTime(endTime)),
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(errorText!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;

  const _TimeBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
