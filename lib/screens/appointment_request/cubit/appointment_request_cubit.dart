import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'dart:typed_data';
import 'package:phsyio_up/models/appointment_request.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/screens/accept_appointment/Ui/accept_appointment.dart';
import 'dart:convert';
import 'dart:async';
part 'appointment_request_state.dart';

List<AppointmentRequest> requests = [];
List<Appointment> appointments = [];

class AppointmentRequestCubit extends Cubit<AppointmentRequestState> {
  AppointmentRequestCubit() : super(AppointmentRequestInitial());
  static AppointmentRequestCubit get(context) => AppointmentRequestCubit();

  // Track SSE connection status
  bool _isConnected = false;
  StreamSubscription? _sseSubscription;
  Timer? _reconnectTimer;
  int _retryCount = 0;
  static const int _maxRetryCount = 5;
  static const int _initialRetryDelay = 2; // seconds
  
  Future<void> fetchData() async {
    emit(FetchDataLoading());
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchRequestedAppointments");
      requests = (response as List<dynamic>?)?.map((e) => AppointmentRequest.fromJson(e)).toList() ?? [];
      response = await getData("$ServerIP/api/protected/FetchUnassignedAppointments");
      appointments = (response as List<dynamic>?)?.map((e) => Appointment.fromJson(e)).toList() ?? [];
      emit(FetchDataSuccess(requests, appointments));
    } catch (e) {
      emit(FetchDataError("Error fetching data: $e"));
    }
  }

  void connectToSSE() async {
    // Prevent multiple connections
    if (_isConnected) return;
    
    print("Connecting to SSE");
    final sseUrl = "$ServerIP/api/protected/RequestSSE";

    try {
      final response = await dio.get<ResponseBody>(
        sseUrl,
        options: Options(
          responseType: ResponseType.stream,
          // Add authentication headers if needed
          // headers: {"Authorization": "Bearer $token"},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 0), // No timeout for receiving SSE
        ),
      );

      // Connection established, reset retry count
      _retryCount = 0;
      _isConnected = true;
      
      // Cancel any pending reconnection
      _reconnectTimer?.cancel();

      _sseSubscription = response.data?.stream
          .map((Uint8List event) => utf8.decode(event)) 
          .transform(const LineSplitter())
          .listen(
        (data) {
          // Handle incoming SSE data
          if (data.trim().isEmpty) return; // Skip empty lines
          
          try {
            // Check if the data is a heartbeat or a message
            if (data.startsWith("data: ")) {
              final eventData = data.substring(6);
              
              if (eventData.contains("refresh")) {
                print("SSE received refresh event");
                fetchData();
              } else {
                // Handle other event types if needed
                print("SSE received: $eventData");
              }
            }
          } catch (e) {
            print("Error processing SSE data: $e");
          }
        },
        onError: (error) {
          print("SSE Error: $error");
          _isConnected = false;
          _cleanupConnection();
          _scheduleReconnect();
        },
        onDone: () {
          print("SSE connection closed");
          _isConnected = false;
          _cleanupConnection();
          _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print("Error connecting to SSE: $e");
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    // Implement exponential backoff strategy
    if (_retryCount < _maxRetryCount) {
      final delay = _initialRetryDelay * (1 << _retryCount); // Exponential backoff
      print("Scheduling SSE reconnection in $delay seconds (attempt ${_retryCount + 1})");
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(seconds: delay), () {
        _retryCount++;
        connectToSSE();
      });
    } else {
      print("Max reconnection attempts reached. SSE connection abandoned.");
      emit(SseConnectionFailed("Connection to server updates failed after $_maxRetryCount attempts"));
    }
  }

  void _cleanupConnection() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  // Close all connections when the cubit is closed
  @override
  Future<void> close() {
    _cleanupConnection();
    _reconnectTimer?.cancel();
    return super.close();
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
        builder: (context) => TreatmentPlanScreen(patientId: appointment.patientID, appointmentId: appointmentId, requestedPlanDesc: ""),
      ),
    );
  }

  Future<String?> handleReject(int requestId, BuildContext context) async {
    final url = "$ServerIP/api/protected/RejectAppointment";
    final data = {
      "ID": requestId,
    };

    try {
      var response = await postData(url, data);
      if (response is DioException) {
        print(response);
        return response.response?.data["error"] ?? "An unknown error occurred";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment rejected successfully")),
      );
      fetchData();
      return null;
    } catch (e) {
      print("Error rejecting appointment: $e");
      return "An error occurred while rejecting the appointment.";
    }
  }
}