import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/dialog.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/screens/login/Ui/login_screen.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  
  static RegisterCubit get(context) => BlocProvider.of(context);
  
  TextEditingController clinicNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  
  Future<void> register(BuildContext context) async {
    emit(RegisterLoading());
    
    if (clinicNameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter clinic name and password"),
          backgroundColor: Colors.red
        ),
      );
      return;
    }
    
    isLoading = true;
    emit(RegisterSuccess());
    try {
      showLoadingDialog(context);
      var response = await dio.post("$ServerIP/api/register/ClinicGroup", data: {
        "name": clinicNameController.text,
        "password": passwordController.text
      });
      print(response);
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    } catch (e) {
      showErrorDialogLogin(
        context,
        e is DioException && e.response?.statusCode == 409
          ? "Clinic name already exists"
          : "Registration failed"
      );
    } finally {
      isLoading = false;
      emit(RegisterSuccess());
    }
  }
  
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(RegisterPasswordVisibility(isPasswordVisible));
  }
}