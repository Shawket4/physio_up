import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';

class EditReferralScreen extends StatefulWidget {
  final Referral referral;
  const EditReferralScreen({super.key, required this.referral});

  @override
  _EditReferralScreenState createState() => _EditReferralScreenState();
}

class _EditReferralScreenState extends State<EditReferralScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _cashbackPercentage;

  // Dropdown value for gender

  @override
  void initState() {
    super.initState();

    // Initialize controllers (empty for create screen)
    _nameController = TextEditingController(text: widget.referral.name);
    _cashbackPercentage = TextEditingController(text: widget.referral.cashbackPercentage.toString());
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _nameController.dispose();
   _cashbackPercentage.dispose();
    super.dispose();
  }

  Future<void> _editReferral() async {
    if (_formKey.currentState!.validate()) {
      // Create new patient object
      final newReferral = Referral(
        id: widget.referral.id, // ID will be assigned by the backend
        name: _nameController.text,
        cashbackPercentage: double.parse(_cashbackPercentage.text), treatmentPlans: null,
      );

      // Call the API to create the new patient
      try {
        final response = await postData(
          "$ServerIP/api/protected/EditReferral", // Replace with your API endpoint
          newReferral.toJson(), // Convert patient object to JSON
        );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Referral Edited Successfully')),
          );
          Navigator.push(context, MaterialPageRoute(builder: (_) => MainWidget()));
       
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error editing referral: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Referral'),
      ),
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
                onPressed: _editReferral,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Text('Edit Referral'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}