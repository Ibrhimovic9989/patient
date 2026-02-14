import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:patient/presentation/assessments/models/assessment_card_model.dart';
import 'package:patient/repository/supabase_assessments_repository.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TherapistProvider with ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _therapists = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get therapists => _therapists;
  bool get isLoading => _isLoading;

  // Fetch Therapists from Supabase
  Future<void> fetchTherapists() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await supabase.from("therapist").select();
      _therapists = List<Map<String, dynamic>>.from(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      print("Error fetching therapists: $e");
      notifyListeners();
    }
  }

  // Book Appointment with Therapist
  Future<void> bookAppointment(BuildContext context, Map<String, dynamic> therapist, String patientId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Appointment"),
        content: Text("Are you sure you want to book an appointment with ${therapist["name"]}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    );

    if (!confirm) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch patient's active package if exists
      final packageResponse = await supabase
          .from('patient_package')
          .select('package_id, id, clinic_id')
          .eq('patient_id', patientId)
          .eq('status', 'active')
          .maybeSingle();
      
      final sessionData = {
        "therapist_id": therapist["id"],
        "patient_id": patientId,
        "timestamp": DateTime.now().toIso8601String(),
        "mode": 1,
        "duration": 60,
        "name": therapist["name"],
        "status": "pending"
      };
      
      if (packageResponse != null) {
        sessionData["package_id"] = packageResponse["package_id"];
        sessionData["patient_package_id"] = packageResponse["id"];
        sessionData["clinic_id"] = packageResponse["clinic_id"];
      }
      
      await supabase.from("session").insert(sessionData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully!"))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error booking appointment: $e"))
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
