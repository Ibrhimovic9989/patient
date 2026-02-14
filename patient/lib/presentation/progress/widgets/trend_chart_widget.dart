import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:patient/model/progress_models/progress_metrics_model.dart';
import 'package:intl/intl.dart';

class TrendChartWidget extends StatelessWidget {
  const TrendChartWidget({
    super.key,
    required this.trendsData,
    this.chartType = ChartType.goals,
  });

  final List<HistoricalTrendData> trendsData;
  final ChartType chartType;

  @override
  Widget build(BuildContext context) {
    if (trendsData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text(
            'No data available for the selected period',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxValue() / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: trendsData.length > 7 ? (trendsData.length / 7).ceil().toDouble() : 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < trendsData.length) {
                    final date = trendsData[value.toInt()].date;
                    final parts = date.split('-');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${parts[2]}/${parts[1]}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          minX: 0,
          maxX: (trendsData.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxValue() * 1.2,
          lineBarsData: [
            LineChartBarData(
              spots: trendsData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                double yValue = 0;
                switch (chartType) {
                  case ChartType.goals:
                    yValue = data.goalsCount.toDouble();
                    break;
                  case ChartType.observations:
                    yValue = data.observationsCount.toDouble();
                    break;
                  case ChartType.regressions:
                    yValue = data.regressionsCount.toDouble();
                    break;
                }
                return FlSpot(index.toDouble(), yValue);
              }).toList(),
              isCurved: true,
              color: _getChartColor(),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: trendsData.length <= 14, // Only show dots if not too many points
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: _getChartColor(),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: _getChartColor().withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxValue() {
    if (trendsData.isEmpty) return 10;
    
    double max = 0;
    for (final data in trendsData) {
      double value = 0;
      switch (chartType) {
        case ChartType.goals:
          value = data.goalsCount.toDouble();
          break;
        case ChartType.observations:
          value = data.observationsCount.toDouble();
          break;
        case ChartType.regressions:
          value = data.regressionsCount.toDouble();
          break;
      }
      if (value > max) max = value;
    }
    return max > 0 ? max : 10;
  }

  Color _getChartColor() {
    switch (chartType) {
      case ChartType.goals:
        return const Color(0xFF7A86F8);
      case ChartType.observations:
        return Colors.green;
      case ChartType.regressions:
        return Colors.orange;
    }
  }
}

enum ChartType {
  goals,
  observations,
  regressions,
}
