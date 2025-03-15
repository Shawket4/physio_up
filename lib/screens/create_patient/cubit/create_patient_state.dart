part of 'create_patient_cubit.dart';

@immutable
sealed class CreatePatientState {}

final class CreatePatientInitial extends CreatePatientState {}

final class CreatePatientLoading extends CreatePatientState {}

final class CreatePatientSuccess extends CreatePatientState {}

final class CreatePatientFailed extends CreatePatientState {
  final String error;
  CreatePatientFailed(this.error);
}
