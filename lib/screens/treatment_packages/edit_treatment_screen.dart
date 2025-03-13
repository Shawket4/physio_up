import 'package:flutter/material.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';

class EditTreatmentScreen extends StatefulWidget {
  final SuperTreatmentPlan treatmentPackage;
  const EditTreatmentScreen({super.key, required this.treatmentPackage});

  @override
  _EditTreatmentScreenState createState() => _EditTreatmentScreenState();
}

class _EditTreatmentScreenState extends State<EditTreatmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _descriptionController;
  late TextEditingController _sessionsCountController;
  late TextEditingController _priceController;

  // Dropdown value for gender

  @override
  void initState() {
    super.initState();

    // Initialize controllers (empty for create screen)
    _descriptionController = TextEditingController(text: widget.treatmentPackage.description);
    _sessionsCountController = TextEditingController(text: widget.treatmentPackage.sessionsCount.toString());
    _priceController = TextEditingController(text: widget.treatmentPackage.price.toString());
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _descriptionController.dispose();
   _sessionsCountController.dispose();
   _priceController.dispose();
    super.dispose();
  }

  Future<void> _editTreatment() async {
    if (_formKey.currentState!.validate()) {
      // Create new patient object
      final newTreatmentPackage = SuperTreatmentPlan(
        id: widget.treatmentPackage.id, // ID will be assigned by the backend
        description: _descriptionController.text,
        sessionsCount: int.parse(_sessionsCountController.text),
        price: double.parse(_priceController.text),
      );

      // Call the API to create the new patient
      try {
        final response = await postData(
          "$ServerIP/api/protected/EditSuperTreatment", // Replace with your API endpoint
          newTreatmentPackage.toJsonWithID(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Treatment Package Edited Successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error editing treatment package: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Edit Package", actions: []),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
               TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20,),
              TextFormField(
                controller: _sessionsCountController,
                decoration: const InputDecoration(
    labelText: 'Sessions Count', prefixIcon: Icon(Icons.numbers),
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value != null && value.isNotEmpty) {
      final count = double.tryParse(value);
      if (count == null || count < 1 || count > 100) {
        return "Enter a valid count (1-100)";
      }
    }
    return null;
  },
              ),
               const SizedBox(height: 20,),
               TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
    labelText: 'Price', prefixIcon: Icon(Icons.money),
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter A Correct Price";
    }
    return null;
  },
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _editTreatment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Text('Edit Package'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}