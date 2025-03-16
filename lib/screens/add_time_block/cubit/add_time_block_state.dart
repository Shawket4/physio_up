part of 'add_time_block_cubit.dart';

@immutable
sealed class AddTimeBlockState {}

final class AddTimeBlockInitial extends AddTimeBlockState {}

final class ToggleSelection extends AddTimeBlockState {}

final class SetDate extends AddTimeBlockState {
  final DateTime date;
  SetDate(this.date);
}
