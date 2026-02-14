import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:clinic/repository/clinic_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePackageScreen extends StatefulWidget {
  final String clinicId;

  const CreatePackageScreen({
    super.key,
    required this.clinicId,
  });

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final _repository = ClinicRepository(Supabase.instance.client);
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _validityController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<Map<String, dynamic>> _therapyTypes = [];
  List<Map<String, dynamic>> _selectedTherapies = [];
  bool _isLoading = false;
  bool _loadingTherapies = true;

  @override
  void initState() {
    super.initState();
    _loadTherapyTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _validityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTherapyTypes() async {
    try {
      _therapyTypes = await _repository.getTherapyTypes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading therapy types: $e')),
        );
      }
    } finally {
      setState(() => _loadingTherapies = false);
    }
  }

  void _addTherapyDetail() {
    showDialog(
      context: context,
      builder: (context) => _TherapyDetailDialog(
        therapyTypes: _therapyTypes,
        onSave: (detail) {
          setState(() {
            _selectedTherapies.add(detail);
          });
        },
      ),
    );
  }

  void _removeTherapyDetail(int index) {
    setState(() {
      _selectedTherapies.removeAt(index);
    });
  }

  Future<void> _createPackage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTherapies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one therapy type')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _repository.createPackage(
        clinicId: widget.clinicId,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        validityDays: int.parse(_validityController.text),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        therapyDetails: _selectedTherapies,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating package: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Package'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter package name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (USD) *',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _validityController,
                decoration: const InputDecoration(
                  labelText: 'Validity (Days) *',
                  border: OutlineInputBorder(),
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter validity days';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Therapy Details *',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addTherapyDetail,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Therapy'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedTherapies.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No therapies added. Click "Add Therapy" to add one.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._selectedTherapies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final therapy = entry.value;
                  final therapyType = _therapyTypes.firstWhere(
                    (t) => t['id'] == therapy['therapy_type_id'],
                    orElse: () => {'name': 'Unknown'},
                  );
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(therapyType['name'] as String? ?? 'Unknown'),
                      subtitle: Text(
                        '${therapy['session_count']} sessions, '
                        '${therapy['frequency_per_week'] ?? 'N/A'}x/week, '
                        '${therapy['session_duration_minutes'] ?? 'N/A'} min',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTherapyDetail(index),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createPackage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Create Package',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TherapyDetailDialog extends StatefulWidget {
  final List<Map<String, dynamic>> therapyTypes;
  final Function(Map<String, dynamic>) onSave;

  const _TherapyDetailDialog({
    required this.therapyTypes,
    required this.onSave,
  });

  @override
  State<_TherapyDetailDialog> createState() => _TherapyDetailDialogState();
}

class _TherapyDetailDialogState extends State<_TherapyDetailDialog> {
  final _sessionCountController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  String? _selectedTherapyId;

  @override
  void dispose() {
    _sessionCountController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedTherapyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a therapy type')),
      );
      return;
    }

    widget.onSave({
      'therapy_type_id': _selectedTherapyId,
      'session_count': int.parse(_sessionCountController.text),
      'frequency_per_week': int.tryParse(_frequencyController.text),
      'session_duration_minutes': int.tryParse(_durationController.text),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Therapy Detail'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedTherapyId,
              decoration: const InputDecoration(
                labelText: 'Therapy Type *',
                border: OutlineInputBorder(),
              ),
              items: widget.therapyTypes.map((therapy) {
                return DropdownMenuItem(
                  value: therapy['id'] as String,
                  child: Text(therapy['name'] as String? ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedTherapyId = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sessionCountController,
              decoration: const InputDecoration(
                labelText: 'Session Count *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _frequencyController,
              decoration: const InputDecoration(
                labelText: 'Frequency per Week',
                border: OutlineInputBorder(),
                hintText: 'e.g., 2',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
                hintText: 'e.g., 60',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
