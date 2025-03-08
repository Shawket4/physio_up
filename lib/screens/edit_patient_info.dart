import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/secretary/router.dart'; // Import your API helper

class PatientEditScreen extends StatefulWidget {
  final Patient patient;

  const PatientEditScreen({super.key, required this.patient});

  @override
  _PatientEditScreenState createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends State<PatientEditScreen> {
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

    // Initialize controllers with patient data
    _nameController = TextEditingController(text: widget.patient.name);
    _phoneController = TextEditingController(text: widget.patient.phone);
    _ageController = TextEditingController(text: widget.patient.age.toString());
    _weightController = TextEditingController(text: widget.patient.weight.toString());
    _heightController = TextEditingController(text: widget.patient.height.toString());
    _diagnosisController = TextEditingController(text: widget.patient.diagnosis);
    _notesController = TextEditingController(text: widget.patient.notes);
    // Set initial gender value
    if (widget.patient.gender != "") {
    _gender = widget.patient.gender;
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    if (_formKey.currentState!.validate()) {
      // Create updated patient object
      final updatedPatient = Patient(
        id: widget.patient.id,
        name: _nameController.text,
        phone: _phoneController.text,
        gender: _gender,
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        history: widget.patient.history,
        requests: widget.patient.requests,
        otp: widget.patient.otp,
        isVerified: widget.patient.isVerified,
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
      );

      // Call the API to save the updated patient data
      try {
        final response = await postData(
          "$ServerIP/api/protected/UpdatePatient", // Replace with your API endpoint
          updatedPatient.toJson(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Patient updated successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating patient: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Patient'),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age',  prefixIcon: Icon(Icons.cake)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'Enter weight in kilograms (kg)',
                  prefixIcon: Icon(Icons.monitor_weight)
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  hintText: 'Enter height in centimeters (cm)',
                  prefixIcon: Icon(Icons.height)
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a height';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
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
                onPressed: _savePatient,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
