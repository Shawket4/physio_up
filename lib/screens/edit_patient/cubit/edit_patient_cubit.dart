import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
part 'edit_patient_state.dart';

class EditPatientCubit extends Cubit<EditPatientState> {
  EditPatientCubit() : super(EditPatientInitial());
  static EditPatientCubit get(context) => BlocProvider.of(context);

  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Controllers for form fields
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late TextEditingController diagnosisController;
  late TextEditingController notesController;

  // Dropdown value for gender
  String gender = 'Male';

  void init(Patient patient) {
    // Initialize controllers with patient data
    nameController = TextEditingController(text: patient.name);
    phoneController = TextEditingController(text: patient.phone);
    ageController = TextEditingController(text: patient.age.toString());
    weightController = TextEditingController(text: patient.weight.toString());
    heightController = TextEditingController(text: patient.height.toString());
    diagnosisController = TextEditingController(text: patient.diagnosis);
    notesController = TextEditingController(text: patient.notes);

    // Set initial gender value
    if (patient.gender != "") {
      gender = patient.gender;
    }
  }

  // Validate phone number format
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    // Basic phone validation - can be adjusted for your region's format
    if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Validate numeric input is positive
  String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    try {
      final number = double.parse(value);
      if (number < 0) {
        return '$fieldName cannot be negative';
      }
    } catch (e) {
      return 'Please enter a valid number';
    }
    return null;
  }

  Future<void> savePatient(Patient patient, BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      emit(SavePatientLoading());

      // Create updated patient object - keeping the same structure as before
      final updatedPatient = Patient(
        id: patient.id,
        name: nameController.text,
        phone: phoneController.text,
        gender: gender,
        age: int.parse(ageController.text),
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
        history: patient.history,
        requests: patient.requests,
        otp: patient.otp,
        isVerified: patient.isVerified,
        diagnosis: diagnosisController.text,
        notes: notesController.text,
      );

      // Call the API to save the updated patient data - same API endpoint and format
      try {
        await postData(
          "$ServerIP/api/protected/UpdatePatient",
          updatedPatient.toJson(),
        );

        // Show success message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainWidget()),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading = false;
        emit(SavePatientSuccess());
      }
    }
  }

  void setGender(String value) {
    gender = value;
    emit(SetGender());
  }
}
