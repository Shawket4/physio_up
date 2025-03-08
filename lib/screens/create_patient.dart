import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/secretary/router.dart'; // Import your API helper

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  _CreatePatientScreenState createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;

  // Dropdown value for gender
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();

    // Initialize controllers (empty for create screen)
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController(text: "0");
    _weightController = TextEditingController(text: "0");
    _heightController = TextEditingController(text: "0");
    _diagnosisController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _createPatient() async {
    if (_formKey.currentState!.validate()) {
      // Create new patient object
      final newPatient = Patient(
        id: 0, // ID will be assigned by the backend
        name: _nameController.text,
        phone: _phoneController.text,
        gender: _gender,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        history: [], // Empty history for new patient
        requests: [], // Empty requests for new patient
        otp: "", // Empty OTP for new patient
        isVerified: false, // Default to false for new patient
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
      );

      // Call the API to create the new patient
      try {
        final response = await postData(
          "$ServerIP/api/protected/CreatePatient", // Replace with your API endpoint
          newPatient.toJson(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient created successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating patient: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
               TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone',  prefixIcon: Icon(Icons.phone)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender',  prefixIcon: Icon(Icons.transgender)),
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age',  prefixIcon: Icon(Icons.cake)),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Enter weight in kilograms (kg)',
                  prefixIcon: Icon(Icons.monitor_weight)
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  hintText: 'Enter height in centimeters (cm)',
                  prefixIcon: Icon(Icons.height)
                ),
                keyboardType: TextInputType.number,
              ),
               TextFormField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: 'Diagnosis',
                  hintText: 'Enter diagnosis',
                    prefixIcon: Icon(Icons.sick)
                ),
              ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Enter notes',
                    prefixIcon: Icon(Icons.notes)
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createPatient,
                child: Text('Create Patient'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}