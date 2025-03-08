import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';

class CreateTreatmentScreen extends StatefulWidget {
  const CreateTreatmentScreen({super.key});

  @override
  _CreateTreatmentScreenState createState() => _CreateTreatmentScreenState();
}

class _CreateTreatmentScreenState extends State<CreateTreatmentScreen> {
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
    _descriptionController = TextEditingController();
    _sessionsCountController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _descriptionController.dispose();
   _sessionsCountController.dispose();
   _priceController.dispose();
    super.dispose();
  }

  Future<void> _addTreatment() async {
    if (_formKey.currentState!.validate()) {
      // Create new patient object
      final newTreatmentPackage = SuperTreatmentPlan(
        description: _descriptionController.text,
        sessionsCount: int.parse(_sessionsCountController.text),
        price: double.parse(_priceController.text),
      );

      // Call the API to create the new patient
      try {
        final response = await postData(
          "$ServerIP/api/protected/AddSuperTreatment", // Replace with your API endpoint
          newTreatmentPackage.toJson(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Treatment Package Added Successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding treatment package: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Treatment Package'),
      ),
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
                onPressed: _addTreatment,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Text('Add Treatment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}