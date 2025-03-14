import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/screens/appointment_request/cubit/appointment_request_cubit.dart';


class AppointmentRequestScreen extends StatefulWidget {
  const AppointmentRequestScreen({super.key});

  @override
  State<AppointmentRequestScreen> createState() =>
      _AppointmentRequestScreenState();
}

class _AppointmentRequestScreenState extends State<AppointmentRequestScreen> {
  String? text;

  @override
  void initState() {
    super.initState();
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

  Widget _buildEmptyState(String message, message2) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Lottie animation for empty state
        message == "You have no pending appointment requests" ?
        Lottie.asset(
          // fit: BoxFit.fill,
          "assets/lottie/Calendar.json",
          height: 180,
          width: 365.4,
          repeat: true,
        ) : Container(),
        const SizedBox(height: 20),
        Text(
          message,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message2,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppointmentRequestCubit()
        ..fetchData()
        ..connectToSSE(),
      child: BlocBuilder<AppointmentRequestCubit, AppointmentRequestState>(
        builder: (context, state) {
          AppointmentRequestCubit cubit = AppointmentRequestCubit.get(context);
                return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
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
                  state is FetchDataLoading
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
                      : state is FetchDataSuccess ? Column(
                          children: [
                            // Appointment Requests Header
                            if (state.requests.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${state.requests.length}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                           state.requests.isEmpty 
    ? _buildEmptyState("You have no pending appointment requests", "The requests are automatically synced")
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    itemCount: state.requests.length,
                                    itemBuilder: (context, index) {
                                      final request = state.requests[index];
                                      return Card(
                                        elevation: 3,
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: Colors.blue.shade100,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.blue.shade50,
                                                    child: Text(
                                                      request.PatientName
                                                              .isNotEmpty
                                                          ? request
                                                              .PatientName[0]
                                                              .toUpperCase()
                                                          : "?",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .blue.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      request.PatientName,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              _buildInfoRow(
                                                Icons.calendar_today,
                                                "Date & Time",
                                                intl.DateFormat(
                                                        "yyyy/MM/dd & h:mm a")
                                                    .format(request
                                                        .timeBlock.dateTime!),
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
                                                request
                                                    .PackageDescriptionRequested,
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      cubit.handleAccept(
                                                          request.ID);
                                                    },
                                                    icon: Icon(Icons.check,
                                                        size: 18),
                                                    label: const Text("Accept"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 10),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      cubit.handleReject(
                                                          request.ID, context);
                                                    },
                                                    icon: Icon(Icons.close,
                                                        size: 18),
                                                    label: const Text("Reject"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 10),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
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
                            if (state.appointments.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${state.appointments.length}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            state.appointments.isEmpty
    ? _buildEmptyState("You have no unconfirmed appointments", "The appointments are automatically synced")
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    itemCount: state.appointments.length,
                                    itemBuilder: (context, index) {
                                      final appointment =
                                          state.appointments[index];
                                      return Card(
                                        elevation: 3,
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          side: BorderSide(
                                            color: Colors.green.shade100,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.green.shade50,
                                                    child: Text(
                                                      appointment.patientName
                                                              .isNotEmpty
                                                          ? appointment
                                                              .patientName[0]
                                                              .toUpperCase()
                                                          : "?",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .green.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      appointment.patientName,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      cubit.handleSetPackage(
                                                          appointment.id,
                                                          context);
                                                    },
                                                    icon: Icon(
                                                        Icons.medical_services,
                                                        size: 18),
                                                    label: const Text(
                                                        "Set Package"),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 10),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
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
                        ) : Container(),
                ],
              ),
            ),
          );
        },
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
}
