import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangePickerDialog2 extends StatefulWidget {
  @override
  _DateRangePickerDialog2State createState() => _DateRangePickerDialog2State();
}

class _DateRangePickerDialog2State extends State<DateRangePickerDialog2> {
  DateTime? _dateFrom;
  DateTime? _dateTo;

  Future<void> _selectDateFrom(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateFrom) {
      setState(() {
        _dateFrom = picked;
      });
    }
  }

  Future<void> _selectDateTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateTo) {
      setState(() {
        _dateTo = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Date Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(_dateFrom == null
                ? 'Select Date From'
                : 'From: ${DateFormat('yyyy-MM-dd').format(_dateFrom!)}'),
            onTap: () => _selectDateFrom(context),
          ),
          ListTile(
            title: Text(_dateTo == null
                ? 'Select Date To'
                : 'To: ${DateFormat('yyyy-MM-dd').format(_dateTo!)}'),
            onTap: () => _selectDateTo(context),
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
            if (_dateFrom != null && _dateTo != null) {
              Navigator.of(context).pop({
                'dateFrom': _dateFrom,
                'dateTo': _dateTo,
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
  }
}