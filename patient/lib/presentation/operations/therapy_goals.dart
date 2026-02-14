import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:patient/provider/therapy_goals_provider.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../gen/assets.gen.dart';
import '../../model/therapy_models/therapy_models.dart';
import '../progress/progress_dashboard_screen.dart';

class TherapyGoalsScreen extends StatefulWidget {
  const TherapyGoalsScreen({super.key});

  @override
  TherapyGoalsScreenState createState() => TherapyGoalsScreenState();
}

class TherapyGoalsScreenState extends State<TherapyGoalsScreen> {
  int selectedTabIndex =
      0; // 0 for Goals, 1 for Observations, 2 for Regression, 3 for Activities
  DateTime selectedDate = DateTime.now();

  // #region agent log
  Future<void> _logDebug(Map<String, dynamic> logData) async {
    try {
      final logFile = File(r'c:\Users\camun\Documents\pts\NeuroTrack\.cursor\debug.log');
      await logFile.writeAsString('${jsonEncode(logData)}\n', mode: FileMode.append);
    } catch (e) {
      // Ignore logging errors
    }
  }
  // #endregion

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TherapyGoalsProvider>();
      provider.loadTherapyTypes();
      provider.fetchTherapyGoals(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final safeAreaInsets = MediaQuery.of(context).padding;
    final availableHeight = screenHeight - safeAreaInsets.top - safeAreaInsets.bottom - 56 - 24; // toolbar height + padding

    // #region agent log
    _logDebug({'location':'therapy_goals.dart:34','message':'Layout constraints','data':{'screenWidth':screenWidth,'screenHeight':screenHeight,'availableHeight':availableHeight,'topInset':safeAreaInsets.top,'bottomInset':safeAreaInsets.bottom},'timestamp':DateTime.now().millisecondsSinceEpoch,'runId':'run1','hypothesisId':'B'});
    // #endregion

    return Scaffold(
      appBar: AppBar(
        title: const Text("Therapy Goals"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProgressDashboardScreen(),
                ),
              );
            },
            tooltip: 'View Progress',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Date Picker Bar
            EasyTheme(
              data: EasyTheme.of(context).copyWith(
                timelineOptions: const TimelineOptions(
                  height: 60,
                ),
              ),
              child: EasyDateTimeLinePicker.itemBuilder(
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                focusedDate: selectedDate,
                itemExtent: screenWidth * 0.2,
                itemBuilder:
                    (context, date, isSelected, isDisabled, isToday, onTap) {
                  return GestureDetector(
                    onTap: onTap,
                    child: SizedBox(
                      height: 20,
                      width: isToday ? screenWidth * 0.25 : screenWidth * 0.2,
                      child: Container(
                        constraints:
                            const BoxConstraints(minHeight: 30, maxHeight: 40),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              isSelected ? const Color(0xFF7A86F8) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          isToday ? "Today" : "${date.day}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onDateChange: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                  context.read<TherapyGoalsProvider>().fetchTherapyGoals(selectedDate);
                },
              ),
            ),

            const SizedBox(height: 12),

            // Therapy Type Filter
            Consumer<TherapyGoalsProvider>(
              builder: (context, provider, child) {
                if (provider.therapyTypes.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: provider.selectedTherapyTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Therapy Type',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Therapy Types'),
                      ),
                      ...provider.therapyTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type.therapyId,
                          child: Text(type.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      provider.setSelectedTherapyTypeId(value);
                      provider.fetchTherapyGoals(selectedDate);
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Therapy Card - Constrained to prevent taking too much space
            Consumer<TherapyGoalsProvider>(
              builder: (context, provider, child) {
                if(provider.apiStatus == ApiStatus.initial) {
                  return const SizedBox.shrink();
                }

                if(provider.apiStatus == ApiStatus.loading) {
                  return const SizedBox(
                    height: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Always show therapy session card from appointments if available (between date picker and tabs)
                if (provider.appointments.isNotEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTherapySessionCardFromAppointment(provider.appointments.first),
                      // Show session notes from therapy goal if available
                      if (provider.therapyGoal != null && 
                          provider.therapyGoal!.sessionNotes != null && 
                          provider.therapyGoal!.sessionNotes!.isNotEmpty)
                        _buildSessionNotesCard(provider.therapyGoal!.sessionNotes!),
                    ],
                  );
                }
                
                // If no appointments but therapy goal exists, show therapy goal card
                if (provider.apiStatus == ApiStatus.success && provider.therapyGoal != null) {
                  return _buildTherapyGoalCard(provider);
                }
                
                // If no appointments and no therapy goal, don't show anything
                return const SizedBox.shrink();
            }),

            const SizedBox(height: 10),

            // Tab Selection
            Container(
              padding: const EdgeInsets.all(6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(250, 250, 250, 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildTabButton("Goals", 0)),
                  Expanded(child: _buildTabButton("Observations", 1)),
                  Expanded(child: _buildTabButton("Regression", 2)),
                  Expanded(child: _buildTabButton("Activities", 3)),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Content Display
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(250, 250, 250, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildContent(selectedTabIndex),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: selectedTabIndex == index
              ? const Color(0xFF7A86F8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: selectedTabIndex == index ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black)),
      ],
    );
  }

  Widget _buildContent(int index) {
    final therapyGoal = context.watch<TherapyGoalsProvider>().therapyGoal;

    return Consumer<TherapyGoalsProvider>(builder: (context, provider, child) {
      if(provider.apiStatus == ApiStatus.initial) {
        return const SizedBox.shrink();
      }

      if (provider.apiStatus == ApiStatus.loading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (provider.apiStatus == ApiStatus.failure) {
        // Show appropriate message based on tab
        String message;
        if (index == 0) {
          message = 'No goals noted today';
        } else if (index == 1) {
          message = 'No observations noted today';
        } else if (index == 2) {
          message = 'No regressions noted today';
        } else {
          message = 'No activities noted today';
        }
        return Center(
          child: Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        );
      }

      List<TherapyModel> therapyGoalModel;

      if(index == 0) {
        therapyGoalModel = provider.therapyGoal?.goals ?? [];
      } else if (index == 1) {
        therapyGoalModel = provider.therapyGoal?.observations ?? [];
      } else if (index == 2) {
        therapyGoalModel = provider.therapyGoal?.regressions ?? [];
      } else {
        therapyGoalModel = provider.therapyGoal?.activities ?? [];
      }

      if(therapyGoal == null || therapyGoalModel.isEmpty) {
        // Show appropriate message based on tab
        String message;
        if (index == 0) {
          message = 'No goals noted today';
        } else if (index == 1) {
          message = 'No observations noted today';
        } else if (index == 2) {
          message = 'No regressions noted today';
        } else {
          message = 'No activities noted today';
        }
        return Center(
          child: Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: therapyGoalModel.length,
        itemBuilder: (context, i) {
          final goal = therapyGoalModel[i];
          final achievementStatus = provider.therapyGoal?.goalAchievementStatus?[goal.id];
          
          IconData? statusIcon;
          Color? statusColor;
          
          if (achievementStatus == 'achieved') {
            statusIcon = Icons.check_circle;
            statusColor = Colors.green;
          } else if (achievementStatus == 'in_progress') {
            statusIcon = Icons.hourglass_empty;
            statusColor = Colors.orange;
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                if (statusIcon != null) ...[
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    "${i + 1}. ${goal.name}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      fontWeight: achievementStatus == 'achieved' ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildTherapySessionCardFromAppointment(Map<String, dynamic> appointment) {
    final timestamp = DateTime.parse(appointment['timestamp']);
    final isCompleted = appointment['is_completed'] as bool? ?? false;
    final isConsultation = appointment['is_consultation'] as bool? ?? false;
    final status = appointment['status'] as String? ?? 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConsultation ? 'Consultation' : 'Therapy Session',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (appointment['therapy_type_name'] != null)
                        Text(
                          appointment['therapy_type_name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.green.shade100 
                        : (status == 'completed' 
                            ? Colors.blue.shade100 
                            : Colors.orange.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted || status == 'completed'
                        ? 'Completed'
                        : 'Upcoming',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || status == 'completed'
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (appointment['therapist_name'] != null)
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Therapist: ${appointment['therapist_name']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${_formatDateTime(timestamp)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${appointment['duration'] ?? 60} mins',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionNotesCard(String sessionNotes) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(82, 158, 158, 158),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sessionNotes,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyGoalCard(TherapyGoalsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color.fromARGB(82, 158, 158, 158)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    Assets.placeholders.therapistImg.provider(),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.therapyGoal!.therapistName ?? "Therapist Name",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  Text(
                    provider.therapyGoal!.specialization ?? "",
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Therapy Type", provider.therapyGoal!.therapyType ?? "N/A"),
              _buildInfoColumn("Therapist", provider.therapyGoal!.therapistName ?? "N/A"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Done at", provider.therapyGoal!.performedOn.toString().split(" ")[0]),
              _buildInfoColumn("Therapy Mode", provider.therapyGoal?.therapyMode == 1 ? "Online" : "Offline"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Duration", "${provider.therapyGoal!.duration} mins"),
              const SizedBox(width: 0),
            ],
          ),
          // Display session notes if available
          if (provider.therapyGoal!.sessionNotes != null && provider.therapyGoal!.sessionNotes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Session Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.therapyGoal!.sessionNotes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final timestamp = DateTime.parse(appointment['timestamp']);
        final isCompleted = appointment['is_completed'] as bool? ?? false;
        final isConsultation = appointment['is_consultation'] as bool? ?? false;
        final status = appointment['status'] as String? ?? 'pending';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConsultation ? 'Consultation' : 'Therapy Session',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (appointment['therapy_type_name'] != null)
                            Text(
                              appointment['therapy_type_name'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? Colors.green.shade100 
                            : (status == 'completed' 
                                ? Colors.blue.shade100 
                                : Colors.orange.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCompleted || status == 'completed'
                            ? 'Completed'
                            : 'Upcoming',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCompleted || status == 'completed'
                              ? Colors.green.shade800
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (appointment['therapist_name'] != null)
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Therapist: ${appointment['therapist_name']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDateTime(timestamp)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${appointment['duration'] ?? 60} mins',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }
}
