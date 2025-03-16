part of 'therapist_schedule_cubit.dart';

@immutable
abstract class TherapistScheduleState {}

class TherapistScheduleInitial extends TherapistScheduleState {}

class TherapistScheduleLoading extends TherapistScheduleState {}

class TherapistScheduleLoaded extends TherapistScheduleState {
  final Therapist therapist;
  
  TherapistScheduleLoaded(this.therapist);
}

class TherapistScheduleError extends TherapistScheduleState {
  final String message;
  
  TherapistScheduleError(this.message);
}