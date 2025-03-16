// ignore_for_file: deprecated_member_use
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/accept_appointment/cubit/accept_appointment_cubit.dart';

class TreatmentPlanScreen extends StatefulWidget {
  final int patientId;
  final int appointmentId;
  final String requestedPlanDesc;
  const TreatmentPlanScreen({
    super.key,
    required this.patientId,
    required this.appointmentId,
    required this.requestedPlanDesc,
  });

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AcceptAppointmentCubit(),
      child: BlocBuilder<AcceptAppointmentCubit, AcceptAppointmentState>(
        builder: (context, state) {
          final cubit = AcceptAppointmentCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Package", actions: []),
            body: FutureBuilder(
              future: cubit.fetchPatientCurrentPackage(widget.patientId,widget.requestedPlanDesc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
                } else {
                  return cubit.showSuperTreatmentDropdown
                      ? _buildSuperTreatmentDropdown(cubit)
                      : _buildTreatmentPlanDetails(cubit);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuperTreatmentDropdown(AcceptAppointmentCubit cubit) {
    double total = cubit.superTreatmentPlans
            .where((SuperTreatmentPlan plan) =>
                plan.id == cubit.selectedSuperTreatmentPlanId)
            .first
            .price! *
        ((100 - double.parse(cubit.discountController.text))) /
        100;

    double cashback = cubit.selectedReferral != null
        ? total * (cubit.selectedReferral!.cashbackPercentage! / 100)
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.blue.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    "Select Package",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: cubit.selectedSuperTreatmentPlanId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Package",
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      prefixIcon: Icon(Icons.medical_services,
                          color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.05),
                    ),
                    items: cubit.superTreatmentPlans.map((plan) {
                      return DropdownMenuItem<int>(
                        value: plan.id,
                        child: Text(
                          "${plan.description} - \$${plan.price}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      cubit.setSelectedSuperTreatmentPlanId(value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Referral>(
                    value: cubit.selectedReferral,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: "Referral Source",
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      prefixIcon:
                          Icon(Icons.person_add, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.05),
                    ),
                    items: cubit.referrals.map((referral) {
                      return DropdownMenuItem<Referral>(
                        value: referral,
                        child: Row(
                          children: [
                            Text(
                              referral.name ?? "No Name",
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              " (${referral.cashbackPercentage}% cashback)",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                     cubit.setSelectedReferral(value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: cubit.discountController,
                    onTapOutside: (event) {
                      if (cubit.discountController.text.isEmpty) {
                        cubit.discountController.text = "0.0";
                      }
                      try {
                        double parsedValue =
                            double.parse(cubit.discountController.text);
                        cubit.discountController.text = parsedValue.toString();
                      } catch (e) {
                        cubit.discountController.text = "0.0";
                      }
                      setState(() {});
                    },
                    onFieldSubmitted: (value) {
                      if (cubit.discountController.text.isEmpty) {
                        cubit.discountController.text = "0.0";
                      }
                      try {
                        double parsedValue =
                            double.parse(cubit.discountController.text);
                        cubit.discountController.text = parsedValue.toString();
                      } catch (e) {
                        cubit.discountController.text = "0.0";
                      }
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: "Discount (%)",
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      prefixIcon:
                          Icon(Icons.discount, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.blue.withOpacity(0.05),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final discount = double.tryParse(value);
                        if (discount == null ||
                            discount < 1 ||
                            discount > 100) {
                          return "Enter a valid discount (1-100)";
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "\$${total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Cashback:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "\$${cashback.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (cubit.selectedSuperTreatmentPlanId != null) {
                          String? response = await cubit.submitAppointment(
                            widget.appointmentId,
                            widget.patientId,
                          );
                          if (response == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Appointment registered successfully"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => MainWidget()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Confirm Package",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentPlanDetails(AcceptAppointmentCubit cubit) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.blue.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Current Package",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          "Remaining Sessions",
                          "${cubit.treatmentPlan.remaining}",
                          Icons.calendar_today,
                        ),
                        Divider(height: 24),
                        _buildDetailRow(
                          "Discount",
                          "${cubit.treatmentPlan.discount}%",
                          Icons.discount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        String? response = await cubit.submitAppointment(
                          widget.appointmentId,
                          widget.patientId,
                        );
                        if (response == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Appointment registered successfully"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => MainWidget()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Confirm Appointment",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue.shade600,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
