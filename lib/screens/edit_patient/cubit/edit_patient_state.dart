part of 'edit_patient_cubit.dart';

@immutable
sealed class EditPatientState {}

final class EditPatientInitial extends EditPatientState {}

final class SavePatientLoading extends EditPatientState {}

final class SavePatientSuccess extends EditPatientState {}

final class SavePatientFailed extends EditPatientState {
  final String error;
  SavePatientFailed(this.error);
}

final class SetGender extends EditPatientState{}