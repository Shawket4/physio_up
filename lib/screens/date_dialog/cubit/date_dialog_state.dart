part of 'date_dialog_cubit.dart';

@immutable
sealed class DateDialogState {}

final class DateDialogInitial extends DateDialogState {}

final class DateFromSelected extends DateDialogState {
  final DateTime dateFrom;
  DateFromSelected(this.dateFrom);
}

final class DateToSelected extends DateDialogState {
  final DateTime dateTo;
  DateToSelected(this.dateTo);
}
