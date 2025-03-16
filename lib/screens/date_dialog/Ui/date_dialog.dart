import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/screens/date_dialog/cubit/date_dialog_cubit.dart';

class DateRangePickerDialog2 extends StatefulWidget {
  @override
  _DateRangePickerDialog2State createState() => _DateRangePickerDialog2State();
}

class _DateRangePickerDialog2State extends State<DateRangePickerDialog2> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DateDialogCubit(),
      child: BlocBuilder<DateDialogCubit, DateDialogState>(
        builder: (context, state) {
          DateDialogCubit cubit = DateDialogCubit.get(context);
          return AlertDialog(
            title: Text('Select Date Range'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(cubit.dateFrom == null
                      ? 'Select Date From'
                      : 'From: ${DateFormat('yyyy-MM-dd').format(cubit.dateFrom!)}'),
                  onTap: () => cubit.selectDateFrom(context),
                ),
                ListTile(
                  title: Text(cubit.dateTo == null
                      ? 'Select Date To'
                      : 'To: ${DateFormat('yyyy-MM-dd').format(cubit.dateTo!)}'),
                  onTap: () => cubit.selectDateTo(context),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (cubit.dateFrom != null && cubit.dateTo != null) {
                    Navigator.of(context).pop({
                      'dateFrom': cubit.dateFrom,
                      'dateTo': cubit.dateTo,
                    }); // Return the selected dates
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select both dates')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}
