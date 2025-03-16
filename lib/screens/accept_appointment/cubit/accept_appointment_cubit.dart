import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
part 'accept_appointment_state.dart';

class AcceptAppointmentCubit extends Cubit<AcceptAppointmentState> {
  AcceptAppointmentCubit() : super(AcceptAppointmentInitial());
  static AcceptAppointmentCubit get(context) => BlocProvider.of(context);

  TreatmentPlan treatmentPlan = TreatmentPlan();
  List<SuperTreatmentPlan> superTreatmentPlans = [];
  bool showSuperTreatmentDropdown = false;
  int? selectedSuperTreatmentPlanId;
  final TextEditingController discountController = TextEditingController(text: "0");
  List<Referral> referrals = [];
  Referral? selectedReferral;

  var isLoaded = false;
  Future<String> fetchPatientCurrentPackage(int patientId,String requestedPlanDesc) async {
    if (isLoaded) {
      return "";
    }
    try {
      await fetchReferrals();
      final response = await postData(
        "$ServerIP/api/protected/FetchPatientCurrentPackage",
        {"patient_id": patientId},
      );
      dynamic treatmentJson = response["treatment_plan"];

      if (treatmentJson != null && treatmentJson["remaining"] != null) {
        treatmentPlan = TreatmentPlan.fromJson(treatmentJson);
        if (response["appointments_count"]! >= treatmentPlan.superTreatmentPlan!.sessionsCount) {
          treatmentPlan.id = 0;
          await fetchSuperTreatments(requestedPlanDesc);
        }
      } else {
        await fetchSuperTreatments(requestedPlanDesc);
      }
      isLoaded = true;
    } catch (e) {
      print("Error fetching patient current package: $e");
      isLoaded = true;
      await fetchSuperTreatments(requestedPlanDesc);
    }
    return "";
  }

  Future<String> fetchSuperTreatments(String requestedPlanDesc) async {
    try {
      final response = await getData("$ServerIP/api/FetchSuperTreatments");

      superTreatmentPlans = (response as List)
          .map((plan) => SuperTreatmentPlan.fromJson(plan))
          .toList();
      showSuperTreatmentDropdown = true;
      SuperTreatmentPlan? requestedPlan = superTreatmentPlans
          .where((SuperTreatmentPlan plan) => plan.description == requestedPlanDesc)
          .firstOrNull;
      if (requestedPlan != null) {
        selectedSuperTreatmentPlanId = requestedPlan.id;
      } else {
        selectedSuperTreatmentPlanId = 1;
      }
    } catch (e) {
      print("Error fetching super treatments: $e");
    }
    return "";
  }

  Future<void> fetchReferrals() async {
    try {
      referrals = await fetchData();
      referrals.add(Referral(id: null, name: "No Referral", cashbackPercentage: 0, treatmentPlans: null));
      referrals = referrals.reversed.toList();
      selectedReferral = referrals[0];
      emit(FetchReferralsSuccess(referrals));
    } catch (e) {
      print("Error fetching referrals: $e");
    }
  }

  Future<List<Referral>> fetchData() async {
    List<Referral> referrals = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchReferrals");
      referrals = (response as List<dynamic>?)
          ?.map((e) => Referral.fromJson(e))
          .toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return referrals;
  }

  Future<String?> submitAppointment(int appointmentId, int patientId) async {
    final url = "$ServerIP/api/protected/RegisterAppointment";
    final data = {
      "appointment_id": appointmentId,
      "treatment_plan": {
        "ID": treatmentPlan.id,
        "super_treatment_plan_id": selectedSuperTreatmentPlanId,
        "referral_id": selectedReferral!.id,
        "discount": discountController.text.isNotEmpty
            ? double.parse(discountController.text)
            : 0,
        "patient_id": patientId,
      },
    };
    print("ID: " + treatmentPlan.id.toString());

    try {
      var response = await postData(url, data);
      print(response);
      if (response is DioException) {
        return response.response?.data["error"] ?? "An unknown error occurred";
      }
      return null; // No error
    } catch (e) {
      print("Error submitting appointment: $e");
      return "An error occurred while submitting the appointment.";
    }
  }
  
  void setSelectedSuperTreatmentPlanId(int id) {
    selectedSuperTreatmentPlanId = id;
    emit(SetSelectedSuperTreatmentPlanId(selectedSuperTreatmentPlanId!));
  }

  void setSelectedReferral(Referral referral) {
    selectedReferral = referral;
    emit(SetSelectedReferral(selectedReferral!));
  }
}
