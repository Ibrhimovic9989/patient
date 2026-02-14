import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:therapist/core/utils/api_status_enum.dart';
import 'package:therapist/provider/daily_activities_provider.dart';

class ActivityCompletionScreen extends StatefulWidget {
  const ActivityCompletionScreen({
    super.key,
    required this.patientId,
    this.activitySetId,
    this.activitySetName,
  });

  final String patientId;
  final String? activitySetId;
  final String? activitySetName;

  @override
  State<ActivityCompletionScreen> createState() => _ActivityCompletionScreenState();
}

class _ActivityCompletionScreenState extends State<ActivityCompletionScreen> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    // Default to last 7 days
    _selectedEndDate = DateTime.now();
    _selectedStartDate = DateTime.now().subtract(const Duration(days: 7));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCompletionData();
    });
  }

  void _loadCompletionData() {
    context.read<DailyActivitiesProvider>().getPatientActivityCompletion(
      widget.patientId,
      activitySetId: widget.activitySetId,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedStartDate != null && _selectedEndDate != null
          ? DateTimeRange(start: _selectedStartDate!, end: _selectedEndDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7A86F8),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked.start;
        _selectedEndDate = picked.end;
      });
      _loadCompletionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activitySetName != null
              ? '${widget.activitySetName} - Completion'
              : 'Activity Completion',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Date Range Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedStartDate != null && _selectedEndDate != null
                                ? '${DateFormat('dd MMM').format(_selectedStartDate!)} - ${DateFormat('dd MMM yyyy').format(_selectedEndDate!)}'
                                : 'Select Date Range',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Completion Data
          Expanded(
            child: Consumer<DailyActivitiesProvider>(
              builder: (context, provider, child) {
                if (provider.activityCompletionStatus == ApiStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.activityCompletionStatus == ApiStatus.failure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          provider.activityCompletionError ?? 'Failed to load completion data',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCompletionData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final completionData = provider.activityCompletionData;
                
                if (completionData.isEmpty) {
                  return const Center(
                    child: Text(
                      'No activity completion data found for the selected period',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: completionData.length,
                  itemBuilder: (context, index) {
                    final data = completionData[index];
                    final date = DateTime.parse(data['date'] as String);
                    final completionRate = (data['completion_rate'] as num).toDouble();
                    final completedCount = data['completed_activities'] as int;
                    final totalCount = data['total_activities'] as int;
                    final items = data['items'] as List<dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('dd MMM yyyy').format(date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: completionRate == 100
                                    ? Colors.green.shade100
                                    : completionRate >= 50
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${completionRate.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: completionRate == 100
                                      ? Colors.green.shade800
                                      : completionRate >= 50
                                          ? Colors.orange.shade800
                                          : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '$completedCount of $totalCount activities completed',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Activity Details:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...items.map((item) {
                                  final isCompleted = item['is_completed'] as bool;
                                  final activityId = item['id'] as String?;
                                  final note = item['note'] as String?;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              isCompleted
                                                  ? Icons.check_circle
                                                  : Icons.radio_button_unchecked,
                                              color: isCompleted ? Colors.green : Colors.grey,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                item['activity'] as String? ?? 'Unknown',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  decoration: isCompleted
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                                  color: isCompleted
                                                      ? Colors.grey
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (note != null && note.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.orange.shade200),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.note,
                                                  size: 16,
                                                  color: Colors.orange.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Parent Note:',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.orange.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        note,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.orange.shade900,
                                                        ),
                                                      ),
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
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
