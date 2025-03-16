// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:phsyio_up/screens/create_patient/ui/create_patient.dart';
import 'package:phsyio_up/screens/edit_patient/Ui/edit_patient_info.dart';
import 'package:phsyio_up/screens/patient/Ui/patient_detail_screen.dart';
import 'package:phsyio_up/screens/patient/cubit/patients_cubit.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientsCubit()..init(),
      child: BlocBuilder<PatientsCubit, PatientsState>(
        builder: (context, state) {
          final cubit = PatientsCubit.get(context);
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreatePatientScreen()));

                if (result == true) {
                  cubit.refreshPatients();
                }
              },
              icon: const Icon(Icons.person_add),
              label: Text(
                'Add Patient',
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w500,
                ),
              ),
              elevation: 4,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: cubit.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search patients by name, ID or phone',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: cubit.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                cubit.searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: cubit.refreshPatients,
                    child: FutureBuilder<List<Patient>>(
                      future: cubit.patientsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !cubit.isRefreshing) {
                          return Center(
                            child: Lottie.asset(
                              "assets/lottie/Loading.json",
                              height: 200,
                              width: 200,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load patients',
                                  style: GoogleFonts.jost(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: cubit.refreshPatients,
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    'Try Again',
                                    style: GoogleFonts.jost(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final patients = snapshot.data ?? [];
                        final filteredPatients = cubit.filterPatients(patients);

                        if (patients.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No patients found',
                                  style: GoogleFonts.jost(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    const CreatePatientScreen()))
                                        .then((value) {
                                      if (value == true) {
                                        cubit.refreshPatients();
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.person_add),
                                  label: Text(
                                    'Add Your First Patient',
                                    style: GoogleFonts.jost(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (filteredPatients.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results found for "$cubit.searchQuery"',
                                  style: GoogleFonts.jost(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    cubit.searchController.clear();
                                  },
                                  icon: const Icon(Icons.clear),
                                  label: Text(
                                    'Clear Search',
                                    style: GoogleFonts.jost(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredPatients.length,
                          itemBuilder: (context, index) {
                            final patient = filteredPatients[index];
                            return PatientCard(
                              patient: patient,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientDetailScreen(patient: patient),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    cubit.refreshPatients();
                                  }
                                });
                              },
                              onDelete: () => cubit.deletePatient(patient,context),
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientEditScreen(patient: patient),
                                  ),
                                ).then((value) {
                                  if (value == true) {
                                    cubit.refreshPatients();
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                  style: GoogleFonts.jost(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: GoogleFonts.jost(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: ${patient.id}",
                      style: GoogleFonts.jost(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          patient.phone.isEmpty ? "No phone" : patient.phone,
                          style: GoogleFonts.jost(
                            fontSize: 14,
                            color: patient.phone.isEmpty
                                ? Colors.grey.shade500
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Edit patient',
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                tooltip: 'Delete patient',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
