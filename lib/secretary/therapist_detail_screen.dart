import 'package:flutter/material.dart';
import 'package:phsyio_up/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/dio_helper.dart';

class TherapistDetailsScreen extends StatefulWidget {
  final Therapist therapist;

  const TherapistDetailsScreen({super.key, required this.therapist});

  @override
  State<TherapistDetailsScreen> createState() => _TherapistDetailsScreenState();
}

 DateTime today = DateTime.now();
class _TherapistDetailsScreenState extends State<TherapistDetailsScreen> {
  DateTime _selectedDay = DateTime(today.year, today.month, today.day);
  Map<DateTime, List<TimeBlock>> _bookedSlots = {};

  @override
  void initState() {
    super.initState();
    _bookedSlots = _fetchBookedSlots();
  }

  /// Extracts and correctly parses date/time blocks
  Map<DateTime, List<TimeBlock>> _fetchBookedSlots() {
    Map<DateTime, List<TimeBlock>> bookedSlots = {};

    for (var block in widget.therapist.schedule?.timeBlocks ?? []) {
      try {
        String dateString = block.date.split(" & ")[0].trim();
        DateTime parsedDate = DateFormat("yyyy/MM/dd").parse(dateString);
        DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        bookedSlots.putIfAbsent(normalizedDate, () => []).add(block);
      } catch (e) {
        print("Error parsing date: ${block.date} - $e");
      }
    }
    setState(() {

    });
    return bookedSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.therapist.name)),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(Duration(days: 365)),  
            lastDay: DateTime.now().add(Duration(days: 365)),  
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              });
              print(_selectedDay);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: -1,
                    child: Container(
                      width: 6, // Small dot
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black, // Customize dot color
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            eventLoader: (day) {
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              return _bookedSlots[normalizedDay] ?? [];
            },
          ),
          Expanded(
            child: ListView(
              children: _bookedSlots[_selectedDay]?.map((block) {
                    String time = block.date.split('&')[1].trim(); // Extract time part
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Time: $time"),
                        subtitle: Text("Patient: ${block.appointment?.patientName == "" ? "Blocked" : block.appointment?.patientName}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                             block.appointment!.patientName == "" ? Container() :
                                IconButton(
                                  icon: Icon(Icons.done, color: block.appointment!.isCompleted ? Colors.green : Colors.grey),
                                  onPressed: () async =>  block.appointment!.isCompleted ? await _unmarkAsCompleted(block.appointment!.id) : await _markAsCompleted(block.appointment!.id),
                                ),
                                block.appointment!.isCompleted ? Container() :
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAppointment(block.id),
                                ),
                          ],
                        ),
                      ),
                    );
                  }).toList() ??
                  [Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No bookings on this date.")))],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsCompleted(int appointmentId) async {
    try {
      await postData(
      "$ServerIP/api/protected/MarkAppointmentAsCompleted",
        {"ID": appointmentId},
      );

       for (var day in _bookedSlots.values) {
          for (var block in day) {
          if (block.appointment!.id == appointmentId) {
            _bookedSlots.values.firstWhere((element) => element == day).firstWhere((block2) => block2==block).appointment!.isCompleted = true;

            setState(() {
              
            });
          }
          }
        }

      
    } catch (e) {
      print("Error updating price: $e");
    }
  }

  Future<void> _unmarkAsCompleted(int appointmentId) async {
    try {
      await postData(
      "$ServerIP/api/protected/UnmarkAppointmentAsCompleted",
        {"ID": appointmentId},
      );

       for (var day in _bookedSlots.values) {
          for (var block in day) {
          if (block.appointment!.id == appointmentId) {
            _bookedSlots.values.firstWhere((element) => element == day).firstWhere((block2) => block2==block).appointment!.isCompleted = false;

            setState(() {
              
            });
          }
          }
        }

      
    } catch (e) {
      print("Error updating price: $e");
    }
  }

  Future<void> _deleteAppointment(int timeBlockId) async {
    try {
      await postData(
        "$ServerIP/api/protected/RemoveAppointment",
        {"ID": timeBlockId},
      );

    for (var day in _bookedSlots.values) {
          for (var block in day) {
          if (block.id == timeBlockId) {
            _bookedSlots.values.firstWhere((element) => element == day).remove(block);
            setState(() {
              
            });
          }
          }
        }
    } catch (e) {
      print("Error deleting appointment: $e");
    }
  }
}

