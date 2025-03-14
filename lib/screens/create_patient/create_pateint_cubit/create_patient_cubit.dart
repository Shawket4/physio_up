import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
part 'create_patient_state.dart';

class CreatePatientCubit extends Cubit<CreatePatientState> {
  CreatePatientCubit() : super(CreatePatientInitial());
  static CreatePatientCubit get(context) => BlocProvider.of(context);

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

  void init() {
    nameController = TextEditingController();
    phoneController = TextEditingController();
    ageController = TextEditingController(text: "0");
    weightController = TextEditingController(text: "0");
    heightController = TextEditingController(text: "0");
    diagnosisController = TextEditingController();
    notesController = TextEditingController();
  }

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

  Future<void> createPatient(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      isLoading = true;
      emit(CreatePatientLoading());
      // Create new patient object - keeping the same structure as before
      final newPatient = Patient(
        id: 0, // ID will be assigned by the backend
        name: nameController.text,
        phone: phoneController.text,
        gender: gender,
        age: int.parse(ageController.text),
        weight: double.parse(weightController.text),
        height: double.parse(heightController.text),
        history: [], // Empty history for new patient
        requests: [], // Empty requests for new patient
        otp: "", // Empty OTP for new patient
        isVerified: false, // Default to false for new patient
        diagnosis: diagnosisController.text,
        notes: notesController.text,
      );

      // Call the API to create the new patient - same API endpoint and format
      try {
        await postData(
          "$ServerIP/api/protected/CreatePatient",
          newPatient.toJson(),
        );

        // Show success message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MainWidget()));
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading = false;
        emit(CreatePatientSuccess());
      }
    }
  }
}
