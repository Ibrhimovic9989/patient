import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapist/presentation/auth/widgets/therapist_time_picker.dart';

import '../../core/common/chips_input_field.dart';
import '../../core/entities/auth_entities/therapist_personal_info_entity.dart';
import '../../provider/auth_provider.dart';
import '../../provider/therapist_provider.dart';
import '../home/home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final licenseController = TextEditingController();
  String selectedGender = '';
  List<String> selectedTherapies = [];
  bool _isLoading = true;

  // Form validation
  final _formKey = GlobalKey<FormState>();

  // Selected values
  int? selectedProfessionId;
  String? selectedProfessionName;
  String? selectedRegulatoryBody;
  String? selectedSpecialization;
  String? selectedAvailabilityStartTime;
  String? selectedAvailabilityEndTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final therapistDataProvider = Provider.of<TherapistDataProvider>(context, listen: false);
      
      // Load professions
      await therapistDataProvider.fetchProfessions();
      
      // Load existing therapist data
      final success = await authProvider.getPersonalInfo();
      
      if (success && authProvider.personalInfo != null) {
        final data = authProvider.personalInfo!;
        
        // Populate form fields
        nameController.text = data['name'] ?? '';
        ageController.text = data['age']?.toString() ?? '';
        licenseController.text = data['license_number'] ?? '';
        selectedGender = data['gender'] ?? '';
        selectedTherapies = List<String>.from(data['offered_therapies'] ?? []);
        selectedRegulatoryBody = data['regulatory_body'];
        selectedSpecialization = data['specialisation'] ?? '';
        selectedAvailabilityStartTime = data['start_availability_time'];
        selectedAvailabilityEndTime = data['end_availability_time'];
        
        // Note: profession_id and profession_name are not stored in therapist table
        // We'll need to infer or set defaults
        if (therapistDataProvider.professions.isNotEmpty) {
          selectedProfessionId = therapistDataProvider.professions.first.id;
          selectedProfessionName = therapistDataProvider.professions.first.name;
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  bool get _checkIfMandatoryFieldsFilled {
    if (selectedGender.isEmpty ||
        (selectedSpecialization?.isEmpty ?? true) ||
        selectedTherapies.isEmpty ||
        selectedAvailabilityStartTime == null ||
        selectedAvailabilityEndTime == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final therapistDataProvider = Provider.of<TherapistDataProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: FilledButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              if (!_checkIfMandatoryFieldsFilled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Create therapist personal info entity
              final personalInfo = TherapistPersonalInfoEntity(
                name: nameController.text,
                age: int.parse(ageController.text),
                gender: selectedGender,
                professionId: selectedProfessionId ?? 1, // Default if not set
                professionName: selectedProfessionName ?? 'Therapist',
                regulatoryBody: selectedRegulatoryBody?.isNotEmpty == true ? selectedRegulatoryBody : null,
                licenseNumber: licenseController.text.isNotEmpty ? licenseController.text : null,
                specialization: selectedSpecialization ?? '',
                therapies: selectedTherapies,
                id: authProvider.userId!,
                startAvailabilityTime: selectedAvailabilityStartTime?.isNotEmpty == true ? selectedAvailabilityStartTime : null,
                endAvailabilityTime: selectedAvailabilityEndTime?.isNotEmpty == true ? selectedAvailabilityEndTime : null,
              );

              // Update in Supabase
              final success = await authProvider.updatePersonalInfo(personalInfo);

              if (success) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: authProvider.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Edit Profile",
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Update your personal information',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(92, 93, 103, 1)),
                ),
                const SizedBox(height: 42),
                _buildTextField(
                  label: 'Full Name',
                  controller: nameController,
                  hintText: 'What should we call you?',
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Age',
                  controller: ageController,
                  hintText: 'Your Age',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Please enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildDropDown(
                  headerText: '  Gender',
                  dropdownItems: const [
                    DropdownMenuEntry(value: 'Male', label: 'Male'),
                    DropdownMenuEntry(value: 'Female', label: 'Female'),
                    DropdownMenuEntry(value: 'Others', label: 'Others'),
                  ],
                  initialSelection: selectedGender.isNotEmpty ? selectedGender : null,
                  onSelected: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildDropDown(
                  headerText: '  Regulatory Body',
                  dropdownItems: therapistDataProvider.regulatoryBodyDropdownItems,
                  initialSelection: selectedRegulatoryBody,
                  onSelected: (value) {
                    setState(() {
                      selectedRegulatoryBody = value;
                    });
                    therapistDataProvider.setSelectedRegulatoryBody(value);
                  },
                ),
                const SizedBox(height: 20),
                _buildDropDown(
                  headerText: '  Specialization',
                  dropdownItems: therapistDataProvider.specializationDropdownItems,
                  initialSelection: (selectedSpecialization?.isNotEmpty ?? false) ? selectedSpecialization : null,
                  onSelected: (value) {
                    setState(() {
                      selectedSpecialization = value;
                    });
                    therapistDataProvider.setSelectedSpecialization(value);
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Registration/License Number',
                  controller: licenseController,
                  hintText: 'Enter your registration/license number',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20),
                OfferedTherapiesChoiceChipInput(
                  initialSelected: selectedTherapies,
                  therapies: therapistDataProvider.therapies,
                  onSelectedTherapiesChanged: (value) {
                    setState(() {
                      selectedTherapies = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TherapistTimePicker(
                  initialStartTime: selectedAvailabilityStartTime,
                  initialEndTime: selectedAvailabilityEndTime,
                  onTimeSelected: (start, end) {
                    setState(() {
                      selectedAvailabilityStartTime = start.format(context);
                      selectedAvailabilityEndTime = end.format(context);
                    });
                  },
                ),
                const SizedBox(height: 100), // Extra space for bottom button
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '  $label',
          style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: keyboardType,
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: Colors.blue,
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade600)),
            errorStyle: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Column _buildDropDown<T>({
    required String headerText,
    required List<DropdownMenuEntry<T>> dropdownItems,
    void Function(T)? onSelected,
    T? initialSelection,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          headerText,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        DropdownMenu<T>(
          onSelected: onSelected != null
              ? (T? value) {
                  if (value != null) {
                    onSelected(value);
                  }
                }
              : null,
          initialSelection: initialSelection,
          trailingIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade600,
          ),
          expandedInsets: const EdgeInsets.all(0),
          dropdownMenuEntries: dropdownItems,
          enableFilter: dropdownItems.length > 5,
          enableSearch: dropdownItems.length > 10,
          width: MediaQuery.of(context).size.width - 40,
        ),
      ],
    );
  }
}
