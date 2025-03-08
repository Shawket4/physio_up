import 'package:flutter/material.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/secretary/router.dart';
import 'package:phsyio_up/therapist/add_time_block.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/dio_helper.dart';

class TherapistScheduleScreen extends StatefulWidget {
  const TherapistScheduleScreen({super.key});

  @override
  State<TherapistScheduleScreen> createState() => _TherapistScheduleScreenState();
}
DateTime today = DateTime.now();
late Therapist therapist;
class _TherapistScheduleScreenState extends State<TherapistScheduleScreen> {
  DateTime _selectedDay = DateTime(today.year, today.month, today.day);
  Map<DateTime, List<TimeBlock>> _bookedSlots = {};

  Future<Therapist> _fetchTherapist() async {
    dynamic response = await getData("$ServerIP/api/protected/GetTherapistSchedule");
    therapist = parseTherapist(response);
    _processBookedSlots(therapist);
    return therapist;
  }

  void _processBookedSlots(Therapist therapist) {
    Map<DateTime, List<TimeBlock>> bookedSlots = {};
    for (var block in therapist.schedule?.timeBlocks ?? []) {
      try {
        String dateString = block.date.split(" & ")[0].trim();
        DateTime parsedDate = DateFormat("yyyy/MM/dd").parse(dateString);
        DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        bookedSlots.putIfAbsent(normalizedDate, () => []).add(block);
      } catch (e) {
        print("Error parsing date: ${block.date} - $e");
      }
    }
      _bookedSlots = bookedSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed:  () {
        Navigator.push(context, MaterialPageRoute(builder: (_) =>MultiSelectAppointmentScreen(therapist: therapist)));
      }, child: Icon(Icons.block),),
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text("Therapist Schedule")),
      body: FutureBuilder<Therapist>(
        future: _fetchTherapist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data available"));
          }
      
          return Column(
            children: [
              TableCalendar(
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
              ),
              Expanded(
                child: ListView(
                  children: _bookedSlots[_selectedDay]?.map((block) {
                        String time = block.date.split('&')[1].trim();
                        return Card(
                          margin: const EdgeInsets.all(10),
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
                      [const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No bookings on this date.")))],
                ),
              ),
            ],
          );
        },
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

