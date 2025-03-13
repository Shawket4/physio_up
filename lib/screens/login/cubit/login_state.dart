part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {}

final class LoginFailure extends LoginState {
  final String error;

  LoginFailure(this.error);
}

final class LoginPasswordVisibility extends LoginState {
  final bool obscurePassword;

  LoginPasswordVisibility(this.obscurePassword);
}
