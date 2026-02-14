import 'package:flutter/material.dart';
import 'package:patient/core/theme/theme.dart';
import 'package:patient/core/utils/api_status_enum.dart';
import 'package:patient/presentation/widgets/snackbar_service.dart';
import 'package:patient/provider/package_provider.dart';
import 'package:patient/presentation/auth/consultation_request_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PackageSelectionScreen extends StatefulWidget {
  const PackageSelectionScreen({super.key});

  @override
  State<PackageSelectionScreen> createState() => _PackageSelectionScreenState();
}

class _PackageSelectionScreenState extends State<PackageSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackageProvider>().fetchAvailablePackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final packageProvider = Provider.of<PackageProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Select Therapy Package'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a therapy package',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Select a package that best fits your needs',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _buildPackageList(packageProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageList(PackageProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Error loading packages',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchAvailablePackages(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.availablePackages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No packages available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please contact your clinic for available packages',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: provider.availablePackages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final package = provider.availablePackages[index];
        return _PackageCard(
          package: package,
          onSelect: () => _handlePackageSelection(package['id'] as String),
        );
      },
    );
  }

  void _handlePackageSelection(String packageId) async {
    final packageProvider = context.read<PackageProvider>();
    
    await packageProvider.assignPackage(
      packageId: packageId,
      startsAt: DateTime.now(),
    );

    if (packageProvider.assignPackageStatus.isSuccess) {
      SnackbarService.showSuccess('Package selected successfully!');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsultationRequestScreen(),
          ),
        );
      }
    } else if (packageProvider.assignPackageStatus.isFailure) {
      SnackbarService.showError(
        packageProvider.errorMessage ?? 'Failed to select package',
      );
    }
  }
}

class _PackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onSelect;

  const _PackageCard({
    required this.package,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final price = package['price'] as num?;
    final validityDays = package['validity_days'] as int?;
    final therapyDetails = package['therapy_details'] as List?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      package['name'] as String? ?? 'Package',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (price != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '\$${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                ],
              ),
              if (package['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  package['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (validityDays != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Valid for $validityDays days',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              if (therapyDetails != null && therapyDetails.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Includes:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...therapyDetails.map((therapy) {
                  final therapyName = therapy['therapy_name'] as String? ?? 'Therapy';
                  final sessionCount = therapy['session_count'] as int? ?? 0;
                  final frequency = therapy['frequency_per_week'] as int?;
                  final duration = therapy['session_duration_minutes'] as int?;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$therapyName: $sessionCount sessions'
                            '${frequency != null ? ' ($frequency/week)' : ''}'
                            '${duration != null ? ' - ${duration}min each' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onSelect,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Select Package'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
