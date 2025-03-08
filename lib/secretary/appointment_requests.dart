import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/appointment_request.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/secretary/accept_appointment.dart';
import 'dart:convert';

import 'package:phsyio_up/secretary/router.dart';

class AppointmentRequestScreen extends StatefulWidget {
  const AppointmentRequestScreen({super.key});

  @override
  State<AppointmentRequestScreen> createState() => _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  List<AppointmentRequest> _requests = [];
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
      appBar: AppBar(
        title: const Text("Appointment Requests"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          
        ),
        
        
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: Lottie.asset(
                "assets/lottie/Loading.json",
                height: 200,
                width: 200,
              ),
            )
          : _requests.isEmpty
              ? const Center(
                  child: Text("No appointment requests found."),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.PatientName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Date & Time: ${intl.DateFormat("yyyy/MM/dd & h:mm a").format(request.timeBlock.dateTime!)}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Therapist: ${request.TherapistName}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Package Requested: ${request.PackageDescriptionRequested}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle Accept button press
                                    _handleAccept(request.ID);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Accept"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle Reject button press
                                    _handleReject(request.ID);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Reject"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

void _handleAccept(int requestId) {
  // _showAcceptDialog(requestId);

  // Find the selected request based on requestId
  final request = _requests.firstWhere((req) => req.ID == requestId);

  // Navigate to the TreatmentPlanScreen with the patient ID
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TreatmentPlanScreen(patientId: request.PatientID, requestId: requestId, selectedDateTime: request.timeBlock.dateTime!, requestedPlanDesc: request.PackageDescriptionRequested,),
    ),
  );

}

// void _showAcceptDialog(int requestId) {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   // Find the selected request based on requestId
//   final request = _requests.firstWhere((req) => req.ID == requestId);

//   // Use the appointment's existing time as the default value
//   DateTime selectedDateTime = request.timeBlock.dateTime!;

//   String? errorMessage;

//   showDialog(
//     context: context,
//     builder: (context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: const Text("Confirm Appointment"),
//             content: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   if (errorMessage != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Text(
//                         errorMessage!,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   TextFormField(
//                     controller: TextEditingController(
//                       text: intl.DateFormat("yyyy/MM/dd & h:mm a").format(selectedDateTime),
//                     ),
//                     readOnly: true,
//                     decoration: const InputDecoration(labelText: "Date & Time"),
//                     onTap: () async {
//                       DateTime? pickedDate = await showDatePicker(
//                         context: context,
//                         initialDate: selectedDateTime,
//                         firstDate: DateTime.now(),
//                         lastDate: DateTime(2100),
//                       );
//                       if (pickedDate != null) {
//                         TimeOfDay? pickedTime = await showTimePicker(
//                           context: context,
//                           initialTime: TimeOfDay.fromDateTime(selectedDateTime),
//                         );
//                         if (pickedTime != null) {
//                           setState(() {
//                             selectedDateTime = DateTime(
//                               pickedDate.year,
//                               pickedDate.month,
//                               pickedDate.day,
//                               pickedTime.hour,
//                               pickedTime.minute,
//                             );
//                           });
//                         }
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _priceController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(labelText: "Price"),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Please enter a price";
//                       }
//                       if (double.tryParse(value) == null) {
//                         return "Enter a valid number";
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   TextFormField(
//                     controller: _notesController,
//                     decoration: const InputDecoration(labelText: "Notes (optional)"),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Cancel"),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final response = await _submitAppointment(
//                       requestId,
//                       _priceController.text,
//                       _notesController.text,
//                       selectedDateTime, // Pass the selected date-time
//                     );
//                     if (response != null) {
//                       setState(() => errorMessage = response);
//                     } else {
//                       Navigator.pop(context);
//                     }
//                   }
//                 },
//                 child: const Text("Send"),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }




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
