import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/secretary/router.dart';

class TreatmentPlanScreen extends StatefulWidget {
  final int patientId;
  final int requestId;
  final DateTime selectedDateTime;
  final String requestedPlanDesc;
  const TreatmentPlanScreen({
    super.key,
    required this.patientId,
    required this.requestId,
    required this.selectedDateTime,
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
      appBar: AppBar(
        title: const Text("Package"),
        centerTitle: true,
        elevation: 0,
      ),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Select Package",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedSuperTreatmentPlanId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),

                    ),
                    items: _superTreatmentPlans.map((plan) {
                      return DropdownMenuItem<int>(
                        value: plan.id,
                        child: Text(
                          "${plan.description} - ${plan.price}",
                          style: const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSuperTreatmentPlanId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Referral>(
                    value: _selectedReferral,
                    decoration: InputDecoration(
                      labelText: "Referral",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
                              " -> ${referral.cashbackPercentage}%",
                              style: const TextStyle(fontSize: 16),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _discountController,
                    onTapOutside: (event) {
                      
                      if (_discountController.text.isEmpty) {
                        _discountController.text = "0.0";
                      }
                      try {
   
    double parsedValue = double.parse(_discountController.text);
    // If parsing succeeds, update the text with the parsed value (optional)
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
    // If parsing succeeds, update the text with the parsed value (optional)
    _discountController.text = parsedValue.toString();
  } catch (e) {
    _discountController.text = "0.0";
  }
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: "Discount (%)",
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 20),
                  Text(
                    "Total: \$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cashback: \$${cashback.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_selectedSuperTreatmentPlanId != null) {
                        String? response = await _submitAppointment(
                          widget.requestId,
                          widget.selectedDateTime,
                        );
                        if (response == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Appointment registered successfully"),
                            ),
                          );
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainWidget())); // Go back to the previous screen
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response)),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 16),
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
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Current Package",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow("Remaining Sessions", "${_treatmentPlan.remaining}"),
                  _buildDetailRow("Discount", "${_treatmentPlan.discount}%"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      String? response = await _submitAppointment(
                        widget.requestId,
                        widget.selectedDateTime,
                      );
                      if (response == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Appointment registered successfully"),
                          ),
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainWidget())); // Go back to the previous screen
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response)),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 16),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _submitAppointment(int requestId, DateTime selectedDateTime) async {
    final url = "$ServerIP/api/protected/RegisterAppointment";
    final data = {
      "appointment_request_id": requestId,
      "extra": {
        "date_time": intl.DateFormat("yyyy/MM/dd & h:mm a").format(selectedDateTime),
      },
      "treatment_plan": {
        "ID": _treatmentPlan.id,
        "super_treatment_plan_id": _selectedSuperTreatmentPlanId,
        "referral_id": _selectedReferral?.id,
        "discount": _discountController.text.isNotEmpty
            ? double.parse(_discountController.text)
            : 0,
      },
    };


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