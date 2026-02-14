import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patient/core/core.dart';
import 'package:patient/provider/progress_provider.dart';
import 'package:patient/presentation/progress/widgets/trend_chart_widget.dart';
import 'package:intl/intl.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  String _selectedPeriod = 'week'; // week, month
  ChartType _selectedChartType = ChartType.goals;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgressData();
    });
  }

  void _loadProgressData() {
    final provider = context.read<ProgressProvider>();
    final now = DateTime.now();
    DateTime startDate;
    
    if (_selectedPeriod == 'week') {
      startDate = now.subtract(const Duration(days: 7));
    } else {
      startDate = now.subtract(const Duration(days: 30));
    }

    provider.fetchProgressMetrics(
      startDate: startDate,
      endDate: now,
    );
    provider.fetchHistoricalTrends(
      startDate: startDate,
      endDate: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Row(
              children: [
                Expanded(
                  child: _buildPeriodButton('Week', 'week'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPeriodButton('Month', 'month'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Metrics Cards
            Consumer<ProgressProvider>(
              builder: (context, provider, child) {
                if (provider.apiStatus == ApiStatus.loading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (provider.apiStatus == ApiStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        provider.errorMessage ?? 'Failed to load progress data',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final metrics = provider.progressMetrics;
                if (metrics == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No progress data available'),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Metrics Cards Row 1
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Goals Achieved',
                            '${metrics.goalsAchieved}/${metrics.totalGoals}',
                            '${metrics.goalsAchievementRate.toStringAsFixed(1)}%',
                            Icons.flag,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Sessions',
                            '${metrics.sessionsCount}',
                            '${metrics.attendanceRate.toStringAsFixed(1)}% attendance',
                            Icons.event,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Metrics Cards Row 2
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Observations',
                            '${metrics.observationsCount}',
                            'Positive notes',
                            Icons.visibility,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Regressions',
                            '${metrics.regressionsCount}',
                            'Areas to focus',
                            Icons.trending_down,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Chart Type Selector
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildChartTypeButton('Goals', ChartType.goals),
                  _buildChartTypeButton('Observations', ChartType.observations),
                  _buildChartTypeButton('Regressions', ChartType.regressions),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Trend Chart
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _getChartTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Consumer<ProgressProvider>(
                    builder: (context, provider, child) {
                      return TrendChartWidget(
                        trendsData: provider.historicalTrends,
                        chartType: _selectedChartType,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        _loadProgressData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A86F8) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF7A86F8) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartTypeButton(String label, ChartType type) {
    final isSelected = _selectedChartType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7A86F8) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getChartTitle() {
    switch (_selectedChartType) {
      case ChartType.goals:
        return 'Goals Progress';
      case ChartType.observations:
        return 'Observations Trend';
      case ChartType.regressions:
        return 'Regressions Trend';
    }
  }
}
