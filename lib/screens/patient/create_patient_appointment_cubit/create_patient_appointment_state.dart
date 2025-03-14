part of 'create_patient_appointment_cubit.dart';

@immutable
sealed class CreatePatientAppointmentState {}

final class CreatePatientInitial extends CreatePatientAppointmentState {}

final class loadTherapistsLoading extends CreatePatientAppointmentState {}

final class loadTherapistsSuccess extends CreatePatientAppointmentState {
  final List<dynamic> therapists;
  loadTherapistsSuccess(this.therapists);
}

final class loadTherapistsFailed extends CreatePatientAppointmentState {
  final String error;
  loadTherapistsFailed(this.error);
}

final class loadScheduleLoading extends CreatePatientAppointmentState {}

final class loadScheduleSuccess extends CreatePatientAppointmentState {
  final List<TimeBlock> timeBlocks;
  final dynamic therapist;
  loadScheduleSuccess(this.timeBlocks, this.therapist);
}

final class loadScheduleFailed extends CreatePatientAppointmentState {
  final String error;
  loadScheduleFailed(this.error);
}

final class HasDate extends CreatePatientAppointmentState {}

final class SelectTherapist extends CreatePatientAppointmentState {}