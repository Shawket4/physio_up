part of 'patients_cubit.dart';

@immutable
sealed class PatientsState {}

final class PatientsInitial extends PatientsState {}

final class PatientsSearchQueryChanged extends PatientsState {
  final String searchQuery;
  PatientsSearchQueryChanged(this.searchQuery);
}

final class RefreshingPatientsLoading extends PatientsState {}

final class RefreshingPatientsSuccess extends PatientsState {
  final List<Patient> patients;
  RefreshingPatientsSuccess(this.patients);
}

