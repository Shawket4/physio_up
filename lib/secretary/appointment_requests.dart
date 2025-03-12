import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/appointment_request.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/secretary/accept_appointment.dart';
import 'dart:convert';

import 'package:phsyio_up/secretary/router.dart';
import 'package:rive/rive.dart';

class AppointmentRequestScreen extends StatefulWidget {
  const AppointmentRequestScreen({super.key});

  @override
  State<AppointmentRequestScreen> createState() => _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  List<AppointmentRequest> _requests = [];
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String? text;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _connectToSSE();
    _setGreetingText();
  }

  // Set greeting text based on time of day
  void _setGreetingText() {
    DateTime currentDateTime = DateTime.now();
    if (currentDateTime.hour < 12) {
      text = "Morning";
    } else if (currentDateTime.hour < 18) {
      text = "Afternoon";
    } else {
      text = "Evening";
    }
  }

  // Fetch data from the API
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchRequestedAppointments");
      List<AppointmentRequest> requests = [];
      for (var request in response) {
        AppointmentRequest newRequest = AppointmentRequest();
        newRequest.ID = request["ID"];
        newRequest.PatientName = request["patient_name"];
        newRequest.TherapistID = request["therapist_id"];
        newRequest.PatientID = request["patient_id"];
        newRequest.TherapistName = request["therapist_name"];
        newRequest.PackageDescriptionRequested = request["super_treatment_plan_description"];
        var dateTime =
            intl.DateFormat("yyyy/MM/dd & h:mm a").parse(request["date_time"]);
        newRequest.timeBlock.dateTime = dateTime;
        requests.add(newRequest);
      }

      response = await getData("$ServerIP/api/protected/FetchUnassignedAppointments");
      print(response);
     _appointments =  (response as List<dynamic>?)?.map((e) => Appointment.fromJson(e)).toList() ?? [];
      print(_appointments);
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching data: $e");
    }
  }



void _connectToSSE() async {
  final sseUrl = "$ServerIP/api/protected/RequestSSE";

  try {
    final response = await dio.get<ResponseBody>(
      sseUrl,
      options: Options(
        responseType: ResponseType.stream,
      ),
    );

   response.data?.stream
        .map((Uint8List event) => utf8.decode(event)) // Convert Uint8List to String
        .transform(const LineSplitter()) // Split lines
        .listen((data) {
      if (data.contains("refresh")) {
        _fetchData(); // Trigger data refresh
      }
    }, onError: (error) {
      print("SSE Error: $error");
      _reconnect();
    }, onDone: () {
      print("SSE connection closed");
      _reconnect();
    });
  } catch (e) {
    print("Error connecting to SSE: $e");
    _reconnect();
  }
}

void _reconnect() {
  Future.delayed(const Duration(seconds: 5), _connectToSSE);
}


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    // drawer: AppDrawer(),
    body: SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.waves,
                  color: Theme.of(context).primaryColor,
                  size: 26,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Good ${text.toString()}${userInfo.permission == 2 ? ": Dr. ${userInfo.username}" : ""}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Appointment Requests Header
                    if (_requests.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_send,
                              color: Colors.blue.shade800,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Appointment Requests",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_requests.length}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _requests.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No appointment requests found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _requests.length,
                            itemBuilder: (context, index) {
                              final request = _requests[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.blue.shade50,
                                            child: Text(
                                              request.PatientName.isNotEmpty
                                                  ? request.PatientName[0].toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              request.PatientName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoRow(
                                        Icons.calendar_today,
                                        "Date & Time",
                                        intl.DateFormat("yyyy/MM/dd & h:mm a").format(request.timeBlock.dateTime!),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.person,
                                        "Therapist",
                                        request.TherapistName,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.medical_services,
                                        "Package",
                                        request.PackageDescriptionRequested,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _handleAccept(request.ID);
                                            },
                                            icon: Icon(Icons.check, size: 18),
                                            label: const Text("Accept"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _handleReject(request.ID);
                                            },
                                            icon: Icon(Icons.close, size: 18),
                                            label: const Text("Reject"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    // Appointments Header
                    if (_appointments.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_available,
                              color: Colors.blue.shade800,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Appointments",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_appointments.length}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _appointments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "No upcoming appointments found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            itemCount: _appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _appointments[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.green.shade100,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.green.shade50,
                                            child: Text(
                                              appointment.patientName.isNotEmpty
                                                  ? appointment.patientName[0].toUpperCase()
                                                  : "?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade800,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              appointment.patientName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildInfoRow(
                                        Icons.calendar_today,
                                        "Date & Time",
                                        appointment.dateTime,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.person,
                                        "Therapist",
                                        appointment.therapistName,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              _handleSetPackage(appointment.id);
                                            },
                                            icon: Icon(Icons.medical_services, size: 18),
                                            label: const Text("Set Package"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
        ],
      ),
    ),
  );
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        icon,
        size: 18,
        color: Colors.grey.shade600,
      ),
      SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  );
}

Future<String> _handleAccept(int requestId) async {

    final request = _requests.firstWhere((req) => req.ID == requestId);
    final url = "$ServerIP/api/protected/AcceptAppointment";
    final data = {
      "appointment_request_id": requestId,
      "extra": {
        "date_time": intl.DateFormat("yyyy/MM/dd & h:mm a").format(request.timeBlock.dateTime!),
      },
    };
    print(data);
    try {
      var response = await postData(url, data);
      print(response);
      if (response is DioException) {
        return response.response?.data["error"] ?? "An unknown error occurred";
      }
      return ""; // No error
    } catch (e) {
      print("Error submitting appointment: $e");
      return "An error occurred while submitting the appointment.";
    }



}

Future<void> _handleSetPackage(int appointmentId) async {
   final appointment = _appointments.firstWhere((req) => req.id == appointmentId);
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TreatmentPlanScreen(patientId: appointment.patientID, appointmentId: appointmentId, requestedPlanDesc: "",),
    ),
  );
}



  void _handleReject(int requestId) async {
    final url = "$ServerIP/api/protected/RejectAppointment";
  final data = {
    "ID": requestId,
  };


   var response = await postData(url, data);
   if (response is DioException) {
      print(response);
      return response.response?.data["error"] ?? "An unknown error occurred"; // Return error message
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment rejected successfully")),
    );
    _fetchData(); // Refresh the list
    return null;
  }
}
