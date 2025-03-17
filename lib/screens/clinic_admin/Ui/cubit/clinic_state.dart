part of 'clinic_cubit.dart';

@immutable
sealed class ClinicState {}

final class ClinicInitial extends ClinicState {}

final class RefreshTherapistsLoading extends ClinicState {}

final class RefreshTherapistsSuccess extends ClinicState {
  final List<Therapist> therapists;
  RefreshTherapistsSuccess(this.therapists);
}


