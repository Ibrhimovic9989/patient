import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:patient/core/theme/theme.dart';
import 'package:patient/core/utils/api_status_enum.dart';
import 'package:patient/provider/milestones_provider.dart';
import 'package:patient/model/milestones/milestone_insight_model.dart';

class DevelopmentMilestonesScreen extends StatelessWidget {
  const DevelopmentMilestonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Development Milestones'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MilestonesProvider>().analyzeMilestones();
            },
          ),
        ],
      ),
      body: Consumer<MilestonesProvider>(
        builder: (context, provider, child) {
          if (provider.apiStatus == ApiStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.apiStatus == ApiStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage ?? 'Failed to load milestones',
                      style: const TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.analyzeMilestones();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final analysis = provider.analysis;
          if (analysis == null) {
            return const Center(
              child: Text('No milestone data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(analysis.progressSummary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Milestones List
                if (analysis.milestones.isNotEmpty) ...[
                  const Text(
                    'Detected Milestones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.milestones.map((milestone) => _buildMilestoneCard(context, milestone)),
                  const SizedBox(height: 16),
                ],

                // Trends
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Progress Trends',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (analysis.trends.improving.isNotEmpty) ...[
                          _buildTrendSection('Improving', analysis.trends.improving, Colors.green),
                          const SizedBox(height: 8),
                        ],
                        if (analysis.trends.stable.isNotEmpty) ...[
                          _buildTrendSection('Stable', analysis.trends.stable, Colors.blue),
                          const SizedBox(height: 8),
                        ],
                        if (analysis.trends.concerning.isNotEmpty) ...[
                          _buildTrendSection('Needs Attention', analysis.trends.concerning, Colors.orange),
                        ],
                        if (analysis.trends.improving.isEmpty && 
                            analysis.trends.stable.isEmpty && 
                            analysis.trends.concerning.isEmpty) ...[
                          const Text(
                            'No trend data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Recommendations
                if (analysis.recommendations.isNotEmpty) ...[
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...analysis.recommendations.map((rec) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      title: Text(rec),
                    ),
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMilestoneCard(BuildContext context, MilestoneInsightModel milestone) {
    Color statusColor;
    IconData statusIcon;
    switch (milestone.status) {
      case 'achieved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.trending_up;
        break;
      case 'regressed':
        statusColor = Colors.orange;
        statusIcon = Icons.trending_down;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(milestone.title),
        subtitle: Text('${milestone.category} • ${milestone.status}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(milestone.description),
                const SizedBox(height: 12),
                const Text(
                  'Evidence:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.evidence, 
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 20, top: 4),
          child: Text('• $item'),
        )),
      ],
    );
  }
}
