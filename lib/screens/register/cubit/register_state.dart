part of 'register_cubit.dart';

abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String error;
  RegisterError(this.error);
}

class RegisterPasswordVisibility extends RegisterState {
  final bool isVisible;
  RegisterPasswordVisibility(this.isVisible);
}