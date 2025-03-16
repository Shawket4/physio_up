// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/screens/patient_package_appointment/cubit/patient_package_appointment_cubit.dart';

class PatientPackageAppointments extends StatefulWidget {
  final int PackageID;
  const PatientPackageAppointments({super.key, required this.PackageID});

  @override
  State<PatientPackageAppointments> createState() =>
      _PatientPackageAppointmentsState();
}

class _PatientPackageAppointmentsState
    extends State<PatientPackageAppointments> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientPackageAppointmentCubit(),
      child: BlocBuilder<PatientPackageAppointmentCubit, PatientPackageAppointmentState>(
        builder: (context, state) {
          final cubit = PatientPackageAppointmentCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Package Appointments", actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
                tooltip: 'Refresh appointments',
              ),
            ]),
            body: FutureBuilder<List<Appointment>>(
              future: cubit.fetchPatientCurrentPackage(widget.PackageID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          "Error loading appointments",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${snapshot.error}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Try Again"),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "No appointments found",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "There are no scheduled appointments for this package",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  // Group appointments by date
                  final groupedAppointments =
                      cubit.groupAppointmentsByDate(snapshot.data!);
                  // Sort dates in descending order (most recent first)
                  final sortedDates = groupedAppointments.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  // Count completed and pending appointments
                  final completedCount =
                      snapshot.data!.where((a) => a.isCompleted).length;
                  final pendingCount = snapshot.data!.length - completedCount;

                  return Column(
                    children: [
                      // Status summary card
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Appointments Summary",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Total: ${snapshot.data!.length}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusCounter(
                                    context,
                                    "Completed",
                                    completedCount,
                                    Colors.green.shade100,
                                    Colors.green),
                                const SizedBox(width: 8),
                                _buildStatusCounter(
                                    context,
                                    "Pending",
                                    pendingCount,
                                    Colors.orange.shade100,
                                    Colors.orange),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // List of appointments grouped by date
                      Expanded(
                        child: ListView.builder(
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            final date = sortedDates[index];
                            final appointments =
                                groupedAppointments[date] ?? [];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.event,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(
                                        cubit.formatDate(date),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...appointments.map((appointment) =>
                                    _buildAppointmentCard(
                                        context, appointment,cubit)),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCounter(BuildContext context, String label, int count,
      Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment,PatientPackageAppointmentCubit cubit) {
    // Get time from the dateTime string - format is "yyyy/mm/dd & h:mm a"
    final timeDisplay = cubit.extractTimeFromDateTime(appointment.dateTime);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: appointment.isCompleted
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      elevation: 1,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: appointment.isCompleted
              ? Colors.green.shade50
              : Colors.orange.shade50,
          radius: 24,
          child: Icon(
            appointment.isCompleted ? Icons.check_circle : Icons.schedule,
            color: appointment.isCompleted ? Colors.green : Colors.orange,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                appointment.therapistName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: appointment.isCompleted
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                appointment.isCompleted ? "Completed" : "Pending",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: appointment.isCompleted
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                timeDisplay,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
