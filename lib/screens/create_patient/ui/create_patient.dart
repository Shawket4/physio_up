import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/screens/create_patient/cubit/create_patient_cubit.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  _CreatePatientScreenState createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  // Validate phone number format

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePatientCubit()..init(),
      child: BlocBuilder<CreatePatientCubit, CreatePatientState>(
        builder: (context, state) {
          CreatePatientCubit cubit = CreatePatientCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Create Patient Profile", actions: []),
            body: cubit.isLoading
                ? Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  )
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: cubit.formKey,
                        child: ListView(
                          children: [
                            const SizedBox(height: 10),

                            // Personal Information Section
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),

                            TextFormField(
                              controller: cubit.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                                hintText: 'Enter patient\'s full name',
                              ),
                              textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: cubit.phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                                hintText: 'Enter contact number',
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: cubit.validatePhone,
                            ),
                            const SizedBox(height: 16),

                            DropdownButtonFormField<String>(
                              value: cubit.gender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.transgender),
                                border: OutlineInputBorder(),
                              ),
                              items: ['Male', 'Female'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  cubit.gender = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: cubit.ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                prefixIcon: Icon(Icons.cake),
                                border: OutlineInputBorder(),
                                hintText: 'Enter age in years',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) =>
                                  cubit.validatePositiveNumber(value, 'age'),
                            ),

                            const SizedBox(height: 20),

                            // Physical Measurements Section
                            const Text(
                              'Physical Measurements',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: cubit.weightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Weight (kg)',
                                      prefixIcon: Icon(Icons.monitor_weight),
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter weight',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*$')),
                                    ],
                                    validator: (value) =>
                                        cubit.validatePositiveNumber(
                                            value, 'weight'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: cubit.heightController,
                                    decoration: const InputDecoration(
                                      labelText: 'Height (cm)',
                                      prefixIcon: Icon(Icons.height),
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter height',
                                    ),
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*$')),
                                    ],
                                    validator: (value) =>
                                        cubit.validatePositiveNumber(
                                            value, 'height'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Medical Information Section
                            const Text(
                              'Medical Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),

                            TextFormField(
                              controller: cubit.diagnosisController,
                              decoration: const InputDecoration(
                                labelText: 'Diagnosis',
                                prefixIcon: Icon(Icons.sick),
                                border: OutlineInputBorder(),
                                hintText: 'Enter medical diagnosis',
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: cubit.notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes',
                                prefixIcon: Icon(Icons.notes),
                                border: OutlineInputBorder(),
                                hintText: 'Enter additional notes',
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 30),
                            // Submit button
                            ElevatedButton.icon(
                              onPressed: () {
                                cubit.createPatient(context);
                              },
                              icon: const Icon(Icons.save),
                              label: const Text(
                                'Create Patient',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
