import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/screens/create_patient.dart';
import 'package:phsyio_up/screens/patient_detail_screen.dart';

import 'package:phsyio_up/secretary/router.dart';


class PatientListScreen extends StatefulWidget {

  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {

  Future<List<Patient>> _fetchData() async {
      List<Patient> patients = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchPatients");
      // print(response);
      patients = parsePatients(response);
    } catch (e) {
      print("Error fetching data: $e");
    }
    return patients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePatientScreen()));
      },
      child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Patients')),
      drawer: AppDrawer(),
      body: Center(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
            return  snapshot.data!.isEmpty ? Text("No Patients Found.") :
             ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final patient = snapshot.data![index];
                return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailScreen(patient: patient),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                   Text("ID: ${patient.id}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                      SizedBox(height: 5),
                  Text("Phone: ${patient.phone.isEmpty ? "N/A" : patient.phone}"),
                ],
              ),
              
               IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                 try {
                        await postData(
                          "$ServerIP/api/protected/DeletePatient",
                          {"patient_id": patient.id},
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Patient Deleted!")),
                          );
                          setState(() {
                            
                          });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("An Error Occured!")),
                          );
                        print("Error deleting referral: $e");
                      }
                              },
                            ),
            ],
          ),
        ),
      ),
    );
    
              },
            );
          }
          },
        ),
      ),
    );
  }
}

