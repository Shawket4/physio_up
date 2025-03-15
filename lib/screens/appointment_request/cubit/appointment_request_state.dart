part of 'appointment_request_cubit.dart';

@immutable
sealed class AppointmentRequestState {}

final class AppointmentRequestInitial extends AppointmentRequestState {}

final class FetchDataLoading extends AppointmentRequestState {}

final class FetchDataSuccess extends AppointmentRequestState {
  final List<AppointmentRequest> requests;
  final List<Appointment> appointments;

  FetchDataSuccess(this.requests, this.appointments);
}

final class FetchDataError extends AppointmentRequestState {
  final String error;

  FetchDataError(this.error);
}

final class SseConnectionFailed extends AppointmentRequestState {
  final String message;

  SseConnectionFailed(this.message);
}