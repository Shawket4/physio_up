import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/components/dialog.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  
  static LoginCubit get(context) => BlocProvider.of(context);


  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> handleLogin(BuildContext context) async {
    emit(LoginLoading());
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter username and password"),
            backgroundColor: Colors.red),
      );
      return;
    }
      isLoading = true;
      emit(LoginSuccess());
    

    try {
      showLoadingDialog(context);
      var response = await dio.post("$ServerIP/api/login", data: {
        "username": usernameController.text,
        "password": passwordController.text
      });

      if (response.data["message"] == "Login Successful") {
        var jwt = response.data["jwt"];
        if (await SetJwt(jwt)) {
          dio.options.headers['Authorization'] = "Bearer $jwt";
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => MainWidget()));
        }
      }
    } catch (e) {
      showErrorDialogLogin(
          context,
          e is DioException && e.response?.statusCode == 401
              ? "Account Frozen"
              : "Invalid Credentials");
    } finally {
     
        isLoading = false;
       emit(LoginSuccess());
    }
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    emit(LoginPasswordVisibility(obscurePassword));
  }
}
