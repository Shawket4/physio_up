import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phsyio_up/models/patient.dart';
part 'patients_state.dart';

class PatientsCubit extends Cubit<PatientsState> {
  PatientsCubit() : super(PatientsInitial());
  static PatientsCubit get(context) => BlocProvider.of(context);

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
    } catch (e) {}
    return treatmentPlan;
  }

  late Future<List<Patient>> patientsFuture;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  bool isRefreshing = false;

  void init() {
    patientsFuture = fetchData();
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    searchQuery = searchController.text.toLowerCase();
    emit(PatientsSearchQueryChanged(searchQuery));
  }

  Future<void> refreshPatients() async {
    
      isRefreshing = true;
      emit(RefreshingPatientsLoading());

    patientsFuture = fetchData();

    
      isRefreshing = false;
      emit(RefreshingPatientsSuccess(await patientsFuture));
  }

  Future<List<Patient>> fetchData() async {
    List<Patient> patients = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchPatients");
      patients = parsePatients(response);
    } catch (e) {
      print("Error fetching data: $e");
      // We'll handle this in the UI
    }
    return patients;
  }

  Future<void> deletePatient(Patient patient,BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Patient',
          style: GoogleFonts.jost(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${patient.name}? This action cannot be undone.',
          style: GoogleFonts.jost(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.jost(),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete),
            label: Text(
              'Delete',
              style: GoogleFonts.jost(),
            ),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await postData(
        "$ServerIP/api/protected/DeletePatient",
        {"patient_id": patient.id},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${patient.name} has been deleted"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'DISMISS',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      // Refresh the list
      refreshPatients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete patient: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Patient> filterPatients(List<Patient> patients) {
    if (searchQuery.isEmpty) {
      return patients;
    }

    return patients.where((patient) {
      return patient.name.toLowerCase().contains(searchQuery) ||
          patient.phone.toLowerCase().contains(searchQuery);
    }).toList();
  }
}
