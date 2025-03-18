import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/dialog.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/therapist.dart';

part 'clinic_state.dart';

class ClinicCubit extends Cubit<ClinicState> {
  ClinicCubit() : super(ClinicInitial());
  static ClinicCubit get(context) => BlocProvider.of(context);

  late Future<List<Therapist>> therapistsFuture;
  bool isRefreshing = false;

  void initList() {
    therapistsFuture = fetchData();
  }

  Future<void> refreshTherapists() async {
    
      isRefreshing = true;
    emit(RefreshTherapistsLoading());
    
    therapistsFuture = fetchData();
    
    
      isRefreshing = false;
    emit(RefreshTherapistsSuccess( await therapistsFuture));
  }

  Future<List<Therapist>> fetchData() async {
    List<Therapist> therapists = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/GetTherapists");
      therapists = parseTherapists(response);
      print(response);
    } catch (e) {
      print("Error fetching data: $e");
      // We'll handle this in the UI
    }
    return therapists;
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  bool isPasswordVisible = false;
  bool isLoading = false;
  
  Future<void> registerTherapist(BuildContext context) async {
    emit(RegisterTherapistLoading());
    
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter username and password"),
          backgroundColor: Colors.red
        ),
      );
      return;
    }
    
    isLoading = true;
    emit(RegisterTherapistSuccess());
    
    try {
      showLoadingDialog(context);
      final response = await postData(
        "$ServerIP/api/protected/RegisterTherapist",
        {"username": usernameController.text, "password": passwordController.text},
      );
      // Close loading dialog
      Navigator.pop(context);
      print(response);
      print(jwt);
      if (response["message"] == "Registered Successfully") {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Therapist registered successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      // Show 
      
    } 
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(RegisterTherapistPasswordVisibility(isPasswordVisible));
  }
}
