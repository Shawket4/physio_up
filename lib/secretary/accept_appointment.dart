import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:intl/intl.dart' as intl;

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
  TreatmentPlan _treatmentPlan = TreatmentPlan();
  List<SuperTreatmentPlan> _superTreatmentPlans = [];
  bool _showSuperTreatmentDropdown = false;
  int? _selectedSuperTreatmentPlanId;
  final TextEditingController _discountController = TextEditingController(text: "0");
  List<Referral> _referrals = [];
  Referral? _selectedReferral;

  @override
  void initState() {
    super.initState();
  
  }

  var isLoaded = false;
  Future<String> _fetchPatientCurrentPackage() async {
    if (isLoaded) {
      return "";
    }
    try {
      await _fetchReferrals();
      final response = await postData(
        "$ServerIP/api/protected/FetchPatientCurrentPackage",
        {"patient_id": widget.patientId},
      );
      print(response);
      if (response != null && response["remaining"] != null) {
        _treatmentPlan = TreatmentPlan.fromJson(response);
        if (_treatmentPlan.remaining! < 1) {
          _treatmentPlan.id = 0;
          await _fetchSuperTreatments();
        }
      } else {
        await _fetchSuperTreatments();
      }
      isLoaded = true;
    } catch (e) {
      print("Error fetching patient current package: $e");
      isLoaded = true;
      await _fetchSuperTreatments();
    }
    return "";
  }

  Future<String> _fetchSuperTreatments() async {
    try {
      final response = await getData("$ServerIP/api/FetchSuperTreatments");

      _superTreatmentPlans = (response as List)
          .map((plan) => SuperTreatmentPlan.fromJson(plan))
          .toList();
      _showSuperTreatmentDropdown = true;
      SuperTreatmentPlan? requestedPlan = _superTreatmentPlans
          .where((SuperTreatmentPlan plan) => plan.description == widget.requestedPlanDesc)
          .firstOrNull;
      if (requestedPlan != null) {
        _selectedSuperTreatmentPlanId = requestedPlan.id;
      } else {
        _selectedSuperTreatmentPlanId = 1;
      }
    } catch (e) {
      print("Error fetching super treatments: $e");
    }
    return "";
  }

  Future<void> _fetchReferrals() async {
    try {
      _referrals = await _fetchData();
      _referrals.add(Referral(id: null, name: "No Referral", cashbackPercentage: 0, treatmentPlans: null));
      _referrals = _referrals.reversed.toList();
      _selectedReferral = _referrals[0];
      setState(() {});
    } catch (e) {
      print("Error fetching referrals: $e");
    }
  }

  Future<List<Referral>> _fetchData() async {
    List<Referral> referrals = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchReferrals");
      referrals = (response as List<dynamic>?)
          ?.map((e) => Referral.fromJson(e))
          .toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return referrals;
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: CustomAppBar(title: "Package", actions: []),
    body: FutureBuilder(
      future: _fetchPatientCurrentPackage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        } else {
          return _showSuperTreatmentDropdown
              ? _buildSuperTreatmentDropdown()
              : _buildTreatmentPlanDetails();
        }
      },
    ),
  );
}

Widget _buildSuperTreatmentDropdown() {
  double total = _superTreatmentPlans
      .where((SuperTreatmentPlan plan) => plan.id == _selectedSuperTreatmentPlanId)
      .first
      .price! *
      ((100 - double.parse(_discountController.text))) /
      100;

  double cashback = _selectedReferral != null
      ? total * (_selectedReferral!.cashbackPercentage! / 100)
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
                  value: _selectedSuperTreatmentPlanId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Package",
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    prefixIcon: Icon(Icons.medical_services, color: Colors.blue.shade700),
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
                  items: _superTreatmentPlans.map((plan) {
                    return DropdownMenuItem<int>(
                      value: plan.id,
                      child: Text(
                        "${plan.description} - \$${plan.price}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSuperTreatmentPlanId = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<Referral>(
                  value: _selectedReferral,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Referral Source",
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    prefixIcon: Icon(Icons.person_add, color: Colors.blue.shade700),
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
                  items: _referrals.map((referral) {
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
                    setState(() {
                      _selectedReferral = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _discountController,
                  onTapOutside: (event) {
                    if (_discountController.text.isEmpty) {
                      _discountController.text = "0.0";
                    }
                    try {
                      double parsedValue = double.parse(_discountController.text);
                      _discountController.text = parsedValue.toString();
                    } catch (e) {
                      _discountController.text = "0.0";
                    }
                    setState(() {});
                  },
                  onFieldSubmitted: (value) {
                    if (_discountController.text.isEmpty) {
                      _discountController.text = "0.0";
                    }
                    try {
                      double parsedValue = double.parse(_discountController.text);
                      _discountController.text = parsedValue.toString();
                    } catch (e) {
                      _discountController.text = "0.0";
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: "Discount (%)",
                    labelStyle: TextStyle(color: Colors.blue.shade700),
                    prefixIcon: Icon(Icons.discount, color: Colors.blue.shade700),
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
                      if (discount == null || discount < 1 || discount > 100) {
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
                      if (_selectedSuperTreatmentPlanId != null) {
                        String? response = await _submitAppointment(
                          widget.appointmentId,
                        );
                        if (response == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Appointment registered successfully"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainWidget()));
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

Widget _buildTreatmentPlanDetails() {
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
                        "${_treatmentPlan.remaining}",
                        Icons.calendar_today,
                      ),
                      Divider(height: 24),
                      _buildDetailRow(
                        "Discount",
                        "${_treatmentPlan.discount}%",
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
                      String? response = await _submitAppointment(
                        widget.appointmentId,
                      );
                      if (response == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Appointment registered successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainWidget()));
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Future<String?> _submitAppointment(int appointmentId) async {
    final url = "$ServerIP/api/protected/RegisterAppointment";
    final data = {
      "appointment_id": appointmentId,
      "treatment_plan": {
        "ID": _treatmentPlan.id,
        "super_treatment_plan_id": _selectedSuperTreatmentPlanId,
        "referral_id": _selectedReferral!.id,
        "discount": _discountController.text.isNotEmpty
            ? double.parse(_discountController.text)
            : 0,
        "patient_id": widget.patientId,
      },
    };
    print("ID: " + _treatmentPlan.id.toString());

    try {
      var response = await postData(url, data);
      print(response);
      if (response is DioException) {
        return response.response?.data["error"] ?? "An unknown error occurred";
      }
      return null; // No error
    } catch (e) {
      print("Error submitting appointment: $e");
      return "An error occurred while submitting the appointment.";
    }
  }
}