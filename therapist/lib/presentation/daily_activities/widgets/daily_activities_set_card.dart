import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'daily_activities_action_btn.dart';
import 'days_of_week.dart';

class ActivitySetCard extends StatefulWidget {
  final String title;
  final bool isExpanded;
  final bool isActive;
  final List<String> activities;
  final String? repeatInfo;
  final String? additionalInfo;
  final VoidCallback onExpandToggle;
  final Function(bool) onActiveToggle;
  final Function(int, bool)? onDaySelected;
  final List<bool> selectedDays;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewCompletion;
  final String startDate;
  final String endDate;

  const ActivitySetCard({
    super.key,
    required this.title,
    required this.isExpanded,
    required this.isActive,
    required this.activities,
    this.repeatInfo,
    this.additionalInfo,
    required this.onExpandToggle,
    required this.onActiveToggle,
    this.onDaySelected,
    required this.selectedDays,
    required this.onEdit,
    required this.onDelete,
    this.onViewCompletion,
    required this.startDate,
    required this.endDate,
  });

  @override
  _ActivitySetCardState createState() => _ActivitySetCardState();
}

class _ActivitySetCardState extends State<ActivitySetCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    widget.isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (!widget.isExpanded) ...[
            // Collapsed view
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show first two activities
                  ...widget.activities.take(2).map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  activity,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  // Additional info
                  if (widget.additionalInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        widget.additionalInfo!,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                    ),

                  // Repeat info and toggle
                  if (widget.repeatInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.repeatInfo!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          Switch(
                            value: widget.isActive,
                            onChanged: widget.onActiveToggle,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFFCB6CE6),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            // Expanded view
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activities
                  ...widget.activities.map(
                    (activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              activity,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              
                  // Repeat info
                  if (widget.repeatInfo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.repeatInfo!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                          ),
                          Switch(
                            value: widget.isActive,
                            onChanged: widget.onActiveToggle,
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFFCB6CE6),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(
                    height: 5,
                  ),

                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),

                  const SizedBox(
                    height: 5,
                  ),
                  // Day selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                          7, (index) => DaysOfWeek(dayIndex: index, isSelected: widget.selectedDays[index])),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.startDate))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(widget.endDate))}',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ),

                  // Action buttons
                   Padding(
                    padding: const  EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        DailyActivitesActionBtn(
                            icon: Icons.edit, label: 'Edit', onTap: widget.onEdit),
                        const SizedBox(height: 12),
                        DailyActivitesActionBtn(
                            icon: Icons.check_circle_outline, 
                            label: 'View Completion', 
                            onTap: widget.onViewCompletion ?? () {}),
                        const SizedBox(height: 12),
                        DailyActivitesActionBtn(
                                icon: Icons.delete_outline, label: 'Delete', onTap: widget.onDelete),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
