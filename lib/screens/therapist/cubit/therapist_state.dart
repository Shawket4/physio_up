part of 'therapist_cubit.dart';

@immutable
sealed class TherapistState {}

final class TherapistInitial extends TherapistState {}

final class FetchBookedSlots extends TherapistState {}

final class MarkAsCompleted extends TherapistState{}

final class UnmarkAsCompleted extends TherapistState{}

final class DeleteAppointment extends TherapistState{}

final class SelectDay extends TherapistState {
  final DateTime selectedDay;
  SelectDay(this.selectedDay);
}

final class RefreshTherapistsLoading extends TherapistState {}

final class RefreshTherapistsSuccess extends TherapistState {
  final List<Therapist> therapists;
  RefreshTherapistsSuccess(this.therapists);
}