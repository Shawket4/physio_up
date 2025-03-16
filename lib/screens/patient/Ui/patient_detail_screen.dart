// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/patient/cubit/patients_cubit.dart';
import 'package:phsyio_up/screens/patient_appointment/Ui/create_patient_appointment.dart';
import 'package:phsyio_up/screens/edit_patient/Ui/edit_patient_info.dart';
import 'package:phsyio_up/screens/patient_package_history/Ui/patient_package_history.dart';
import 'package:phsyio_up/screens/patient_records/Ui/patient_records_folder.dart';
// ignore: non_constant_identifier_names

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => PatientsCubit(),
      child: BlocBuilder<PatientsCubit, PatientsState>(
        builder: (context, state) {
          PatientsCubit cubit = PatientsCubit.get(context);
          return FutureBuilder(
            future: cubit.FetchPatientCurrentPackage(patient.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  ),
                );
              } else {
                TreatmentPlan treatmentPlan = snapshot.data!;
                return BlocProvider(
                  create: (context) => PatientsCubit(),
                  child: BlocBuilder<PatientsCubit, PatientsState>(
                    builder: (context, state) {
                      return Scaffold(
                        floatingActionButton: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FloatingActionButton(
                                heroTag: "appointmentBtn",
                                backgroundColor: theme.primaryColor,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MakeAppointmentScreen(
                                          patientID: patient.id),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.calendar_month),
                                tooltip: 'New Appointment',
                              ),
                              const SizedBox(width: 16),
                              FloatingActionButton(
                                heroTag: "recordsBtn",
                                backgroundColor: theme.primaryColor,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientFileExplorerScreen(
                                          patientID: patient.id),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.folder),
                                tooltip: 'Patient Records',
                              ),
                            ],
                          ),
                        ),
                        appBar:
                            CustomAppBar(title: patient.name, actions: <Widget>[
                          IconButton(
                            tooltip: 'Edit Patient',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PatientEditScreen(patient: patient),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ]),
                        body: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: theme.primaryColor.withOpacity(0.05),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 8, bottom: 8),
                                    child: Text(
                                      "Patient Information",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Patient Details Card
                                        _buildPatientDetailsCard(theme),
                                        const SizedBox(width: 16),
                                        // Package Card
                                        _buildPackageCard(
                                            context, treatmentPlan, theme),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 20,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Appointment History",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Appointments List
                            Expanded(
                              child: patient.history.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "No appointments yet",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      MakeAppointmentScreen(
                                                          patientID:
                                                              patient.id),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text(
                                                "Schedule Appointment"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      itemCount: patient.history.length,
                                      itemBuilder: (context, index) {
                                        final appointment =
                                            patient.history[index];
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 2,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 8),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 8),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  appointment.isCompleted
                                                      ? Colors.green.shade50
                                                      : Colors.orange.shade50,
                                              child: Icon(
                                                appointment.isCompleted
                                                    ? Icons.check
                                                    : Icons.pending,
                                                color: appointment.isCompleted
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                            title: Text(
                                              "${appointment.therapistName}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      appointment.dateTime,
                                                      style: TextStyle(
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.circle,
                                                      size: 8,
                                                      color: appointment
                                                              .isCompleted
                                                          ? Colors.green
                                                          : Colors.orange,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      appointment.isCompleted
                                                          ? "Completed"
                                                          : "Scheduled",
                                                      style: TextStyle(
                                                        color: appointment
                                                                .isCompleted
                                                            ? Colors.green
                                                            : Colors.orange,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.more_vert),
                                              onPressed: () {
                                                // Show options for the appointment
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons.edit),
                                                          title: const Text(
                                                              'Edit Appointment'),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            // Add edit appointment logic
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons.delete),
                                                          title: const Text(
                                                              'Cancel Appointment'),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            // Add cancel appointment logic
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildPatientDetailsCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 200,
          maxWidth: 350,
        ),
        width: null, // Removed fixed width to allow flexible sizing
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.primaryColor.withOpacity(0.2),
                  radius: 24,
                  child: Text(
                    patient.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              patient.phone,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow(Icons.transgender, "Gender", patient.gender),
            _buildDetailRow(Icons.cake, "Age", "${patient.age} years"),
            _buildDetailRow(
                Icons.monitor_weight, "Weight", "${patient.weight} kg"),
            _buildDetailRow(Icons.height, "Height", "${patient.height} cm"),
            const Divider(height: 24),
            _buildDetailRow(Icons.sick, "Diagnosis", patient.diagnosis),
            const SizedBox(height: 8),
            if (patient.notes.isNotEmpty) ...[
              const Text(
                "Notes",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  patient.notes,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(
      BuildContext context, TreatmentPlan treatmentPlan, ThemeData theme) {
    final bool hasActivePackage =
        treatmentPlan.id != 0 && treatmentPlan.id != null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientPackageHistoryScreen(PatientID: patient.id),
        ),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasActivePackage ? "Active Package" : "Package History",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: theme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (hasActivePackage) ...[
                const Divider(),
                Text(
                  treatmentPlan.superTreatmentPlan?.description ??
                      "No description",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Remaining",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${treatmentPlan.remaining}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Used",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${treatmentPlan.superTreatmentPlan!.sessionsCount! - treatmentPlan.remaining!}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Discount",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${treatmentPlan.discount}%",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 32,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "No active package",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to view previous packages",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top for multiline text
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true, // Ensure text wraps
            ),
          ),
        ],
      ),
    );
  }
}
