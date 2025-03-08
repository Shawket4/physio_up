import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/create_patient_appointment.dart';
import 'package:phsyio_up/screens/edit_patient_info.dart';
import 'package:phsyio_up/screens/patient_package_history.dart';
import 'package:phsyio_up/screens/patient_records_folder.dart';



  // ignore: non_constant_identifier_names
  Future<TreatmentPlan> FetchPatientCurrentPackage(int PatientID) async {
    TreatmentPlan treatmentPlan = TreatmentPlan();
    try {
      final response = await postData(
        "$ServerIP/api/protected/FetchPatientCurrentPackage",
        {"patient_id": PatientID},
      );
      if (response != null && response["remaining"] != null) {
        treatmentPlan = TreatmentPlan.fromJson(response);
        if (treatmentPlan.remaining! < 1) {
          treatmentPlan.id = 0;
        }
      }
    // ignore: empty_catches
    } catch (e) {
    }
    return treatmentPlan;
  }

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FetchPatientCurrentPackage(patient.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
        TreatmentPlan treatmentPlan = snapshot.data!;

        return Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MakeAppointmentScreen(patientID: patient.id),
                    ),
                  );
                },
                child: Icon(Icons.add),
              ),
              const SizedBox(width: 20,),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientFileExplorerScreen(patientID: patient.id),
                    ),
                  );
                },
                child: Icon(Icons.folder),
              ),
            ],
          ),
          appBar: AppBar(
            title: Text("Appointments for ${patient.name}"),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientEditScreen(patient: patient),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Patient Details Card
              Scrollbar(
                thumbVisibility: true, // Always show the scrollbar
        trackVisibility: true, // Show the track of the scrollbar
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                    
                      children: [
                        Card(
                              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
                              elevation: 4, // Add shadow
                              shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                              ),
                              child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20,horizontal: 35),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                    "Patient Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800], // Darker text color
                    ),
                                ),
                                SizedBox(height: 16),
                                _buildDetailRow(Icons.person, "Name: ${patient.name}"),
                                _buildDetailRow(Icons.phone, "Phone: ${patient.phone}"),
                                _buildDetailRow(Icons.transgender, "Gender: ${patient.gender}"),
                                _buildDetailRow(Icons.cake, "Age: ${patient.age}"),
                                _buildDetailRow(Icons.monitor_weight, "Weight: ${patient.weight} kg"),
                                _buildDetailRow(Icons.height, "Height: ${patient.height} cm"),
                                _buildDetailRow(Icons.sick, "Diagnosis: ${patient.diagnosis}"),
                                _buildDetailRow(Icons.notes, "Notes: ${patient.notes}")
                              ],
                            ),
                              ),
                            ),
                            const SizedBox(width: 20,),
                            treatmentPlan.id != 0 && treatmentPlan.id != null ?
                            GestureDetector(
                              onTap:() => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientPackageHistoryScreen(PatientID: patient.id,))),
                              child: Card(
                                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
                                elevation: 4, // Add shadow
                                shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                    Padding(
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
                          _buildDetailRowPackage("Description: ", "${treatmentPlan.superTreatmentPlan?.description}"),
                          _buildDetailRowPackage("Sessions Consumed: ", "${treatmentPlan.superTreatmentPlan!.sessionsCount! - treatmentPlan.remaining!}"),
                          _buildDetailRowPackage("Sessions Remaining: ", "${treatmentPlan.remaining}"),
                          _buildDetailRowPackage("Discount: ", "${treatmentPlan.discount}%"),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                                ],
                        ),
                      ),
                              ),
                            ) :  GestureDetector(
                              onTap:() => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientPackageHistoryScreen(PatientID: patient.id,))),
                              child: Card(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
                                elevation: 4, // Add shadow
                                shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Padding(
                        padding: const EdgeInsets.all(16.0),
                    child: Text("Package History"),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
                        // Appointments List
              Expanded(
                child: patient.history.isEmpty
                    ? Center(child: Text("No appointments found"))
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListView.builder(
                          itemCount: patient.history.length,
                          itemBuilder: (context, index) {
                            final appointment = patient.history[index];
                            return Card(
                               shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text("Therapist: ${appointment.therapistName}"),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Date: ${appointment.dateTime}"),
                                      Text("Price: \$${appointment.price.toStringAsFixed(2)}"),
                                      Text("Status: ${appointment.isCompleted ? "Completed" : "Pending"}"),
                                    ],
                                  ),
                                  trailing: appointment.isPaid
                                      ? Icon(Icons.check_circle, color: Colors.green)
                                      : Icon(Icons.pending, color: Colors.orange),
                                ),
                              ),
                            );
                          },
                        ),
                    ),
              ),
            ],
          ),
        );
      }
      }
    );
  }

   Widget _buildDetailRowPackage(String label, String value) {
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

  Widget _buildDetailRow(IconData icon, String text) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blueGrey[600], // Icon color
        ),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[700], // Text color
          ),
        ),
      ],
    ),
  );
}
}