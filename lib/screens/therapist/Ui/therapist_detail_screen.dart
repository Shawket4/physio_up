// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/main.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/components/dio_helper.dart';

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
      appBar: CustomAppBar(title: widget.therapist.name, actions: []),
      body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  });
                },
                eventLoader: (day) => _bookedSlots[DateTime(day.year, day.month, day.day)] ?? [],
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.red.shade300),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: Colors.blue.shade800,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Appointments for ${DateFormat('MMMM d, yyyy').format(_selectedDay)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _bookedSlots[_selectedDay]?.isEmpty ?? true 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No bookings on this date",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _bookedSlots[_selectedDay]?.length ?? 0,
                  itemBuilder: (context, index) {
                    final block = _bookedSlots[_selectedDay]![index];
                    String time = block.date.split('&')[1].trim();
                    bool isBlocked = block.appointment?.patientName == "";
                    bool isCompleted = block.appointment?.isCompleted ?? false;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isBlocked 
                              ? Colors.red.shade200 
                              : isCompleted
                                  ? Colors.green.shade200
                                  : Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isBlocked 
                              ? Colors.red.shade50 
                              : isCompleted
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                          child: Icon(
                            isBlocked 
                                ? Icons.block 
                                : isCompleted
                                    ? Icons.check_circle
                                    : Icons.schedule,
                            color: isBlocked 
                                ? Colors.red.shade700 
                                : isCompleted
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                          ),
                        ),
                        title: Text(
                          "Time: $time",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "Patient: ${isBlocked ? "Blocked" : block.appointment?.patientName}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isBlocked)
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted ? Colors.green.shade50 : Colors.grey.shade100,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.done,
                                    color: isCompleted ? Colors.green : Colors.grey,
                                  ),
                                  tooltip: isCompleted ? "Mark as incomplete" : "Mark as completed",
                                  onPressed: () async => isCompleted 
                                      ? await _unmarkAsCompleted(block.appointment!.id) 
                                      : await _markAsCompleted(block.appointment!.id),
                                ),
                              ),
                            SizedBox(width: 8),
                            if (!isCompleted)
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.shade50,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete, 
                                    color: Colors.red,
                                  ),
                                  tooltip: "Delete appointment",
                                  onPressed: () => _deleteAppointment(block.id),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
        ));
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

