part of 'therapist_schedule_cubit.dart';

@immutable
sealed class TherapistScheduleState {}

final class TherapistScheduleInitial extends TherapistScheduleState {}

final class CalculateVisibleDays extends TherapistScheduleState {}

final class SelectDay extends TherapistScheduleState {}

final class SelectFocusDay extends TherapistScheduleState {}

final class MarkAsCompleted extends TherapistScheduleState{}

final class UnmarkAsCompleted extends TherapistScheduleState{}

final class DeleteAppointment extends TherapistScheduleState{}