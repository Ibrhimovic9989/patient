import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapist/core/utils/api_status_enum.dart';
import 'package:therapist/presentation/daily_activities/widgets/daily_activities_set_card.dart';

import '../../core/common/widgets/primary_button.dart';
import '../../provider/daily_activities_provider.dart';
import 'add_activty_set_screen.dart';
import 'activity_completion_screen.dart';

class DailyActivitiesScreen extends StatefulWidget {
  const DailyActivitiesScreen({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  State<DailyActivitiesScreen> createState() => _DailyActivitiesScreenState();
}

class _DailyActivitiesScreenState extends State<DailyActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<DailyActivitiesProvider>()
          .getDailyActivities(widget.patientId);
    });
  }

  final List<String> weekDays = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  AppBar _getAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Image.asset(
          'assets/arrow_left.png',
          width: 24,
          height: 24,
        ),
      ),
      title: const Text(
        'Daily Activities',
        style: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.assessment, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActivityCompletionScreen(
                  patientId: widget.patientId,
                ),
              ),
            );
          },
          tooltip: 'View All Activity Completions',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: PrimaryButton(
        text: 'Add Activity Set',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddActivitySetScreen(
                  patientId: widget.patientId,
                  onSave: () {
                    context
                        .read<DailyActivitiesProvider>()
                        .getDailyActivities(widget.patientId);
                  },
                ),
              ),
          );
        },
      ),
      backgroundColor: Colors.white,
      appBar: _getAppBar(context),
      body: Consumer<DailyActivitiesProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                if (provider.dailyActivitiesStatus == ApiStatus.loading) ...[
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ] else if (provider.dailyActivitiesStatus ==
                    ApiStatus.success) ...[
                  ListView.builder(
                    primary: false,
                    itemCount: provider.dailyActivities.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final dailyActivity = provider.dailyActivities[index];
                      return ActivitySetCard(
                        startDate: dailyActivity.startTime,
                        endDate: dailyActivity.endTime,
                        onDelete: () {
                          context
                              .read<DailyActivitiesProvider>()
                              .deleteActivitySet(dailyActivity.id, widget.patientId);
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddActivitySetScreen(
                                onSave: () {
                                  context
                                      .read<DailyActivitiesProvider>()
                                      .getDailyActivities(widget.patientId);
                                },
                                patientId: widget.patientId,
                                activitySetId: dailyActivity.id,
                                startDate:
                                    DateTime.parse(dailyActivity.startTime),
                                endDate: DateTime.parse(dailyActivity.endTime),
                                activityName: dailyActivity.activityName,
                                activities: dailyActivity.activityList
                                    .map((e) => e.activity)
                                    .toList(),
                                activityInstructions: () {
                                  final instructionsMap = <String, String>{};
                                  for (final activity in dailyActivity.activityList) {
                                    if (activity.instructions != null && activity.instructions!.isNotEmpty) {
                                      instructionsMap[activity.activity] = activity.instructions!;
                                    }
                                  }
                                  return instructionsMap;
                                }(),
                                selectedWeekdays: () {
                                  final daysOfWeek = dailyActivity.daysOfWeek;
                                  final List<String> selectedDays = [];
                                  for (int i = 0; i < 7; i++) {
                                    if (daysOfWeek.contains(i.toString())) {
                                      selectedDays.add(weekDays[i]);
                                    }
                                  }
                                  return selectedDays;
                                }(),
                              ),
                            ),
                          );
                        },
                        onViewCompletion: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityCompletionScreen(
                                patientId: widget.patientId,
                                activitySetId: dailyActivity.id,
                                activitySetName: dailyActivity.activityName,
                              ),
                            ),
                          );
                        },
                        title: dailyActivity.activityName,
                        isExpanded: provider.isExpanded,
                        isActive: dailyActivity.isActive,
                        activities: dailyActivity.activityList
                            .map((e) => e.activity)
                            .toList(),
                        onExpandToggle: () {
                          provider.toggleExpanded();
                        },
                        onActiveToggle: (bool isActive) {},
                        selectedDays: () {
                          final daysOfWeek = dailyActivity.daysOfWeek;
                          final List<bool> selectedDays = [];
                          for (int i = 0; i < 7; i++) {
                            selectedDays.add(daysOfWeek.contains(i.toString()));
                          }
                          return selectedDays;
                        }(),
                      );
                    },
                  )
                ] else ...[
                  const Center(
                    child: Text('No daily activities found'),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
