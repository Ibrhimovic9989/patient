import 'package:flutter/material.dart';
import 'package:patient/core/theme/theme.dart';
import 'package:patient/presentation/assessments/assessment_screen.dart';
import 'package:patient/presentation/assessments/widgets/assessment_card.dart';
import 'package:patient/provider/assessment_provider.dart';
import 'package:provider/provider.dart';

class AssessmentsListScreen extends StatefulWidget {
  const AssessmentsListScreen({super.key});

  @override
  State<AssessmentsListScreen> createState() => _AssessmentsListScreenState();
}

class _AssessmentsListScreenState extends State<AssessmentsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AssessmentProvider>().fetchAllAssessments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assessmentProvider =
        Provider.of<AssessmentProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Assessment',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Select assessment you\'d like to take',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  color: AppTheme.subtitleColor,
                ),
              ),
              const SizedBox(height: 24),
              Consumer(builder: (context, provider, child) {
                if (assessmentProvider.isLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                if (assessmentProvider.errorMessage != null) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading assessments',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            assessmentProvider.errorMessage ?? 'Unknown error',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              assessmentProvider.fetchAllAssessments();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (assessmentProvider.allAssessments.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assessment_outlined, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No assessments available',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please seed the assessments table in Supabase',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: assessmentProvider.allAssessments.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final assessment =
                          assessmentProvider.allAssessments[index];
                      return AssessmentCard(
                        assessment: assessment,
                        onTap: () {
                          context
                              .read<AssessmentProvider>()
                              .selectedAssessmentId = assessment.assessmentId;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssessmentScreen(
                                assessment: assessment,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
