part of 'clinic_cubit.dart';

@immutable
sealed class ClinicState {}

final class ClinicInitial extends ClinicState {}

final class RefreshTherapistsLoading extends ClinicState {}

final class RefreshTherapistsSuccess extends ClinicState {
  final List<Therapist> therapists;
  RefreshTherapistsSuccess(this.therapists);
}

class RegisterTherapistLoading extends ClinicState {}

class RegisterTherapistSuccess extends ClinicState {}

class RegisterTherapistError extends ClinicState {
  final String error;
  RegisterTherapistError(this.error);
}

class RegisterTherapistPasswordVisibility extends ClinicState {
  final bool isVisible;
  RegisterTherapistPasswordVisibility(this.isVisible);
}

