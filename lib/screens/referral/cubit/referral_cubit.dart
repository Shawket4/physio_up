import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/main.dart';
part 'referral_state.dart';

class ReferralCubit extends Cubit<ReferralState> {
  ReferralCubit() : super(ReferralInitial());
  static ReferralCubit get(context) => BlocProvider.of(context);

  final createFormKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController createNameController;
  late TextEditingController createCashbackPercentage;

  void initAdd(){
   createNameController = TextEditingController();
    createCashbackPercentage = TextEditingController();
  }


  Future<void> createReferral(BuildContext context) async {
    if (createFormKey.currentState!.validate()) {
      // Create new patient object
      final newReferral = Referral(
        id: 0, // ID will be assigned by the backend
        name: createNameController.text,
        cashbackPercentage: double.parse(createCashbackPercentage.text),
        treatmentPlans: null,
      );

      // Call the API to create the new patient
      try {
         await postData(
          "$ServerIP/api/protected/AddReferral", 
          newReferral.toJson(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Referral Created Successfully')),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => MainWidget()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating referral: $e')),
        );
      }
    }
  }

  final editFormKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController editNameController;
  late TextEditingController editCashbackPercentage;


  void initEdit(Referral referral){
    editNameController = TextEditingController(text:referral.name);
    editCashbackPercentage = TextEditingController(
        text: referral.cashbackPercentage.toString());
  }

  Future<void> editReferral(Referral referral,BuildContext context) async {
    if (editFormKey.currentState!.validate()) {
      // Create new patient object
      final newReferral = Referral(
        id: referral.id, // ID will be assigned by the backend
        name: editNameController.text,
        cashbackPercentage: double.parse(editCashbackPercentage.text),
        treatmentPlans: null,
      );

      // Call the API to create the new patient
      try {
        await postData(
          "$ServerIP/api/protected/EditReferral", // Replace with your API endpoint
          newReferral.toJson(), // Convert patient object to JSON
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Referral Edited Successfully')),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => MainWidget()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error editing referral: $e')),
        );
      }
    }
  }

  late Future<List<Referral>> referralsFuture;
  bool isRefreshing = false;

  void initGet() {
    referralsFuture = fetchData();
  }

  Future<List<Referral>> fetchData() async {
    List<Referral> referrals = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchReferrals");
      referrals = (response as List<dynamic>?)?.map((e) => Referral.fromJson(e)).toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return referrals;
  }

  Future<void> refreshData() async {
    emit(RefreshDataLoading());
    isRefreshing = true;
    referralsFuture = fetchData();
    await referralsFuture;
    
    isRefreshing = false;
    emit(RefreshDataSuccess(await referralsFuture)); 
  }

  Future<List<TreatmentPlan>> fetchReferralPackagesData(Referral referral) async {
      List<TreatmentPlan> treatmentPlans = [];
    try {
      dynamic response = await postData("$ServerIP/api/protected/FetchReferralPackages", {
        "referral_id": referral.id,
      });
      print(response);
      treatmentPlans = (response as List<dynamic>?)?.map((e) => TreatmentPlan.fromJson(e)).toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return treatmentPlans;
  }


  late Referral setRefSelectedReferral;
  List<Referral> setRefReferrals = [];
  bool setRefIsLoaded = false;


  Future<String> setRefFetchReferrals(TreatmentPlan package) async {
  if (setRefIsLoaded) {
    return "";
  }
    List<Referral> referrals = [];
        try {
      dynamic response = await getData("$ServerIP/api/protected/FetchReferrals");
      referrals = (response as List<dynamic>?)
          ?.map((e) => Referral.fromJson(e))
          .toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    referrals.add(Referral(id: null, name: "No Referral", cashbackPercentage: 0, treatmentPlans: null));
    setRefReferrals = referrals.reversed.toList();
    if (package.referralID != null) {
      print(package.referralID);
      setRefSelectedReferral = setRefReferrals.firstWhere((referral) => referral.id == package.referralID, orElse: () {
        return setRefReferrals.first;
      });
    } else {
      setRefSelectedReferral = setRefReferrals.first;
    }
    setRefIsLoaded = true;
    return "";
  }

    setReferral(Referral referral){
    setRefSelectedReferral = referral;
    emit(SetReferral(referral));
  }

  Future<String?> setRefSubmitForm(TreatmentPlan package,TextEditingController discountController) async {
    final url = "$ServerIP/api/protected/SetPackageReferral";
    final data = {
      "referral_id": setRefSelectedReferral.id,
      "package_id": package.id,
      "discount": double.parse(discountController.text),
    };

    try {
      var response = await postData(url, data);
      if (response is DioException) {
        return response.response?.data["error"] ?? "An unknown error occurred";
      }
      return null; // No error
    } catch (e) {
      print("Error submitting appointment: $e");
      return "An error occurred while submitting the appointment.";
    }
  }
  
}
