import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:therapist/model/model.dart';

class TherapyTypeField extends StatelessWidget {
  const TherapyTypeField({
    super.key,
    required this.therapyType,
    required this.onChanged,
    this.selectedTherapyType,
  });

  final List<TherapyTypeModel> therapyType;
  final String? selectedTherapyType;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('TherapyTypeField: ${therapyType.length} therapy types available');
      if (therapyType.isNotEmpty) {
        debugPrint('TherapyTypeField: First therapy type - ID: ${therapyType.first.therapyId}, Name: ${therapyType.first.name}');
      }
      debugPrint('TherapyTypeField: Selected value: $selectedTherapyType');
    }
    
    // Validate that selected value exists in items, otherwise set to null
    String? validValue = selectedTherapyType;
    if (validValue != null && therapyType.isNotEmpty) {
      final valueExists = therapyType.any((type) => type.therapyId == validValue);
      if (!valueExists) {
        if (kDebugMode) {
          debugPrint('TherapyTypeField: Selected value does not exist in items, resetting to null');
        }
        validValue = null;
      }
    }
    
    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: therapyType.isEmpty
          ? [
              const DropdownMenuItem(
                value: null,
                enabled: false,
                child: Text(
                  'No therapy types available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]
          : [
              for (final type in therapyType)
                DropdownMenuItem(
                  value: type.therapyId,
                  child: Text(
                    type.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xff121417),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
      onChanged: therapyType.isEmpty 
          ? null 
          : (String? value) {
              if (kDebugMode) {
                debugPrint('TherapyTypeField: onChanged called with value: $value');
              }
              onChanged?.call(value);
            },
      hint: const Text(
        'Select Therapy Type',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xff121417),
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Image.asset('assets/arrow_down.png', width: 20, height: 20),
      ),
      isExpanded: true,
      dropdownColor: Colors.white,
    );
  }
}