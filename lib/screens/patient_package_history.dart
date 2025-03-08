import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/patient_package_appointments.dart';
import 'package:phsyio_up/screens/referral/set_referral_screen.dart';


class PatientPackageHistoryScreen extends StatefulWidget {
  final int PatientID;
  const PatientPackageHistoryScreen({super.key, required this.PatientID});

  @override
  State<PatientPackageHistoryScreen> createState() => _PatientPackageHistoryScreenState();
}

class _PatientPackageHistoryScreenState extends State<PatientPackageHistoryScreen> {

  Future<List<TreatmentPlan>> _fetchPatientPackageHistory() async {
    List<TreatmentPlan> treatmentPlans = [];
    try {
      final response = await postData(
        "$ServerIP/api/protected/FetchPatientPackages",
        {"patient_id": widget.PatientID},
      );
      for (var package in response.reversed.toList()) {
          TreatmentPlan treatmentPlan = TreatmentPlan.fromJson(package);
          treatmentPlans.add(treatmentPlan);
      }

    } catch (e) {
      print("Error fetching patient current package: $e");
    }
    print("object");
    return treatmentPlans;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Package History"),
      ),
      body: FutureBuilder(
        future: _fetchPatientPackageHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final package = snapshot.data![index];
                          return GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientPackageAppointments(PackageID: snapshot.data![index].id!))),
                            child: Card(
                               shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Rounded corners
                                      ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text("Description: ${package.superTreatmentPlan?.description}"),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Date: ${package.date}"),
                                          Text("Price: \$${package.superTreatmentPlan?.price}"),
                                          Text("Discount: ${package.discount}%"),
                                          Text("Total: \$${package.totalPrice!.toStringAsFixed(2)}"),
                                          Text("Remaining Sessions: ${package.remaining}"),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          package.isPaid! ? Icon(Icons.monetization_on, color: Colors.green) : Container(),
                                          package.remaining! < 1
                                      ? Icon(Icons.check_circle, color: Colors.green) : Container(),
                                      PopupMenuButton<String>(
            icon: Icon(Icons.pending, color: Colors.orange),
            onSelected: (String value) async {
              if (value == "set_referral") {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SetReferralScreen(package: package,)));
              } else if (value == "mark_as_paid") {
                try {
                 await postData("$ServerIP/api/protected/MarkPackageAsPaid", {
                  "package_id": package.id,
                });
                 ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Marked Successfully"),
                            ),
                          );
                        setState(() {
                          
                        });
                } catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                }
                
                          
                        
              }
              else if (value == "mark_as_unpaid") {
                try {
                 await postData("$ServerIP/api/protected/UnMarkPackageAsPaid", {
                  "package_id": package.id,
                });
                 ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Unmarked Successfully"),
                            ),
                          );
                          setState(() {
                          
                        });
                } catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                }
                
                          
                        
                        
              }
              
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'set_referral',
                  child: Text('Set Referral'),
                ),
                package.isPaid! ? PopupMenuItem<String>(
                  value: 'mark_as_unpaid',
                  child: Text('Mark As Unpaid'),
                ) :
                PopupMenuItem<String>(
                  value: 'mark_as_paid',
                  child: Text('Mark As Paid'),
                ),
              ];
            },
                                      ),
                                        ],
                                      )
                                    ],
                                  ),
                                
                                  
                                       
                                ),
                              ),
                            ),
                          );
                        },
                      );
          }
      }),
    );
  }
}