import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'dart:typed_data';
import 'package:phsyio_up/models/appointment_request.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/screens/secretary/Ui/accept_appointment.dart';
import 'dart:convert';
part 'appointment_request_state.dart';

List<AppointmentRequest> requests = [];
List<Appointment> appointments = [];

class AppointmentRequestCubit extends Cubit<AppointmentRequestState> {
  AppointmentRequestCubit() : super(AppointmentRequestInitial());
  static AppointmentRequestCubit get(context) => AppointmentRequestCubit();

 
  
  Future<void> fetchData() async {
    
 emit(FetchDataLoading());
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchRequestedAppointments");
     requests = (response as List<dynamic>?)?.map((e) => AppointmentRequest.fromJson(e)).toList() ?? [];
     response = await getData("$ServerIP/api/protected/FetchUnassignedAppointments");
     appointments =  (response as List<dynamic>?)?.map((e) => Appointment.fromJson(e)).toList() ?? [];
      emit(FetchDataSuccess(requests, appointments));
    } catch (e) {
      
      emit(FetchDataError("Error fetching data: $e"));
    }
  }


  void connectToSSE() async {
    print("Connecting to SSE");
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
        fetchData(); // Trigger data refresh
      }
    }, onError: (error) {
      print("SSE Error: $error");
      reconnect();
    }, onDone: () {
      print("SSE connection closed");
      reconnect();
    });
  } catch (e) {
    print("Error connecting to SSE: $e");
    reconnect();
  }
}

void reconnect() {
  Future.delayed(const Duration(seconds: 5), connectToSSE);
}

Future<String> handleAccept(int requestId) async {
    final request = requests.firstWhere((req) => req.ID == requestId);
    final url = "$ServerIP/api/protected/AcceptAppointment";
    final data = {
      "appointment_request_id": requestId,
      "extra": {
        "date_time": intl.DateFormat("yyyy/MM/dd & h:mm a").format(request.timeBlock.dateTime!),
      },
    };

    try {
      var response = await postData(url, data);
      if (response is DioException) {
        return response.response?.data["error"] ?? "An unknown error occurred";
      }
      return ""; // No error
    } catch (e) {
      print("Error submitting appointment: $e");
      return "An error occurred while submitting the appointment.";
    }



}

Future<void> handleSetPackage(int appointmentId, BuildContext context) async {
   final appointment = appointments.firstWhere((req) => req.id == appointmentId);
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TreatmentPlanScreen(patientId: appointment.patientID, appointmentId: appointmentId, requestedPlanDesc: "",),
    ),
  );
}



  void handleReject(int requestId,BuildContext context) async {
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
    fetchData();
    return null;
  }

}
