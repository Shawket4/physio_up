import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/models/treatment_plan.dart';


class SetReferralScreen extends StatefulWidget {
  final TreatmentPlan package;
  const SetReferralScreen({super.key, required this.package});

  @override
  State<SetReferralScreen> createState() => _SetReferralScreenState();
}

  late Referral _selectedReferral;
  List<Referral> _referrals = [];
  bool isLoaded = false;



class _SetReferralScreenState extends State<SetReferralScreen> {
  final TextEditingController _discountController = TextEditingController(text: "0");

Future<String> _fetchReferrals() async {
  if (isLoaded) {
    return "";
  }
    List<Referral> referrals = [];
        try {
      dynamic response = await getData("$ServerIP/api/protected/FetchReferrals");
      referrals = (response as List<dynamic>?)
          ?.map((e) => Referral.fromJson(e))
          .toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    referrals.add(Referral(id: null, name: "No Referral", cashbackPercentage: 0, treatmentPlans: null));
    _referrals = referrals.reversed.toList();
    if (widget.package.referralID != null) {
      print(widget.package.referralID);
      _selectedReferral = _referrals.firstWhere((referral) => referral.id == widget.package.referralID, orElse: () {
        return _referrals.first;
      });
    } else {
      _selectedReferral = _referrals.first;
    }
    isLoaded = true;
    return "";
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Set Package Referral", actions: []),
      body: FutureBuilder(
        future: _fetchReferrals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
          }
          return _buildForm();
        }
      ),
    );
  }

  
  Widget _buildForm() {
       double total = widget.package.superTreatmentPlan!
        .price! *
        ((100 - double.parse(_discountController.text))) /
        100;

    double cashback = total * (_selectedReferral.cashbackPercentage! / 100);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                            referral.name ?? "No Referral",
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
                      _selectedReferral = value!;
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
              String? response = await _submitForm();

               if (response == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Referral Set Successfully"),
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
            
          )
            
        ],
      ),
    );
  }
    Future<String?> _submitForm() async {
    final url = "$ServerIP/api/protected/SetPackageReferral";
    final data = {
      "referral_id": _selectedReferral.id,
      "package_id": widget.package.id,
      "discount": double.parse(_discountController.text),
    };

    try {
      var response = await postData(url, data);
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

