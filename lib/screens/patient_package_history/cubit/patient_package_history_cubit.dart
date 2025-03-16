import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
part 'patient_package_history_state.dart';

class PatientPackageHistoryCubit extends Cubit<PatientPackageHistoryState> {
  PatientPackageHistoryCubit() : super(PatientPackageHistoryInitial());
  static PatientPackageHistoryCubit get(context) => BlocProvider.of(context);

  Future<void> deletePackage(int? packageId,BuildContext context) async {
    if (packageId == null) return;
    
    try {
      await postData("$ServerIP/api/protected/RemovePackage", {
        "id": packageId,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Package deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );  
      emit(DeletePackageSuccess("Package deleted successfully"));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> markPackageAsPaid(int? packageId,BuildContext context) async {
    if (packageId == null) return;
    
    try {
      await postData("$ServerIP/api/protected/MarkPackageAsPaid", {
        "package_id": packageId,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Package marked as paid"),
          backgroundColor: Colors.green,
        ),
      );
      
     emit(MarkPackageAsPaid());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> markPackageAsUnpaid(int? packageId,BuildContext context) async {
    if (packageId == null) return;
    
    try {
      await postData("$ServerIP/api/protected/UnMarkPackageAsPaid", {
        "package_id": packageId,
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Package marked as unpaid"),
          backgroundColor: Colors.green,
        ),
      );
      
      emit(MarkPackageAsUnpaid());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<TreatmentPlan>> fetchPatientPackageHistory(int PatientID) async {
    List<TreatmentPlan> treatmentPlans = [];
    try {
      final response = await postData(
        "$ServerIP/api/protected/FetchPatientPackages",
        {"patient_id": PatientID},
      );
      for (var package in response.reversed.toList()) {
        TreatmentPlan treatmentPlan = TreatmentPlan.fromJson(package);
        treatmentPlans.add(treatmentPlan);
      }
    } catch (e) {
      print("Error fetching patient current package: $e");
    }
    return treatmentPlans;
  }
}
