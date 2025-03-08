import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';

class PatientPackageAppointments extends StatefulWidget {
  final int PackageID;
  const PatientPackageAppointments({super.key, required this.PackageID});

  @override
  State<PatientPackageAppointments> createState() => _PatientPackageAppointmentsState();
}

class _PatientPackageAppointmentsState extends State<PatientPackageAppointments> {
  Future<List<Appointment>> _fetchPatientCurrentPackage() async {
    List<Appointment> appointments = [];
    try {
      final response = await postData(
        "$ServerIP/api/protected/FetchPackageAppointments",
        {"package_id": widget.PackageID},
      );
      for (var appointmentJSON in response.reversed.toList()) {
        Appointment appointment = Appointment.fromJson(appointmentJSON);
        appointments.add(appointment);
      }
    } catch (e) {
      print("Error fetching patient current package: $e");
    }
    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Package Appointments"),
      ),
      body: FutureBuilder(
        future: _fetchPatientCurrentPackage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No appointments found"),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data![index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text("Therapist: ${appointment.therapistName}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${appointment.dateTime}"),
                          Text("Status: ${appointment.isCompleted ? "Completed" : "Pending"}"),
                        ],
                      ),
                      trailing: appointment.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.pending, color: Colors.orange),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}