import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'date_dialog_state.dart';

class DateDialogCubit extends Cubit<DateDialogState> {
  DateDialogCubit() : super(DateDialogInitial());
  static DateDialogCubit get(context) => BlocProvider.of(context);

  DateTime? dateFrom;
  DateTime? dateTo;

  Future<void> selectDateFrom(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateFrom) {
      dateFrom = picked;
      emit(DateFromSelected(dateFrom!));
    }
  }

  Future<void> selectDateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateTo) {
      dateTo = picked;
      emit(DateToSelected(dateTo!));
    }
  }
}
