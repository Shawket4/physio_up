import 'package:flutter/material.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';

class CreateReferralScreen extends StatefulWidget {
  const CreateReferralScreen({super.key});

  @override
  _CreateReferralScreenState createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _cashbackPercentage;

  // Dropdown value for gender

  @override
  void initState() {
    super.initState();

    // Initialize controllers (empty for create screen)
    _nameController = TextEditingController();
    _cashbackPercentage = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
   _cashbackPercentage.dispose();
    super.dispose();
  }

  Future<void> _createReferral() async {
    if (_formKey.currentState!.validate()) {
      // Create new patient object
      final newReferral = Referral(
        id: 0, // ID will be assigned by the backend
        name: _nameController.text,
        cashbackPercentage: double.parse(_cashbackPercentage.text), treatmentPlans: null,
      );

      // Call the API to create the new patient
      try {
        final response = await postData(
          "$ServerIP/api/protected/AddReferral", // Replace with your API endpoint
          newReferral.toJson(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral Created Successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating referral: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Create Referral", actions: []),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
               TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20,),
              TextFormField(
                controller: _cashbackPercentage,
                decoration: const InputDecoration(
    labelText: 'Cashback Percentage', prefixIcon: Icon(Icons.percent),
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value != null && value.isNotEmpty) {
      final discount = double.tryParse(value);
      if (discount == null || discount < 1 || discount > 100) {
        return "Enter a valid percentage (1-100)";
      }
    }
    return null;
  },
              ),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _createReferral,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Text('Create Referral'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}