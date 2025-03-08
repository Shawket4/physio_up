import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/secretary/router.dart';


class MultiSelectAppointmentScreen extends StatefulWidget {
  final Therapist therapist;
  
  const MultiSelectAppointmentScreen({super.key, required this.therapist});

  @override
  State<MultiSelectAppointmentScreen> createState() => _MultiSelectAppointmentScreenState();
}

class _MultiSelectAppointmentScreenState extends State<MultiSelectAppointmentScreen> {
  List<TimeBlock> timeBlocks = [];
  List<DateTime> selectedTimeBlocks = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadBlocks();
    markBookedBlocks();
  }

  void loadBlocks() {
      timeBlocks.clear();
    for (int hour = 11; hour <= 23; hour++) {
      timeBlocks.add(TimeBlock(
        id: 0,
        date:  intl.DateFormat("yyyy/MM/dd & h:mm a").format((DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour, 0))),
        isAvailable: true,
      ));
    }
  }

  void markBookedBlocks() {
    var bookedBlocks = widget.therapist.schedule!.timeBlocks;
    for (var block in bookedBlocks) {
      for (var timeBlock in timeBlocks) {
        if (timeBlock.date == block.date) {
          timeBlock.isAvailable = false;
          break;
        }
      }
    }
  }

  void toggleSelection(DateTime time) {
    setState(() {
      if (selectedTimeBlocks.contains(time)) {
        selectedTimeBlocks.remove(time);
      } else {
        selectedTimeBlocks.add(time);
      }
    });
  }

  Future<void> submitAppointments() async {
    if (selectedTimeBlocks.isEmpty) return;

    List<String> formattedTimes = selectedTimeBlocks.map(
      (dateTime) => intl.DateFormat("yyyy/MM/dd & h:mm a").format(dateTime),
    ).toList();
    print(formattedTimes);
    Map<String, dynamic> data = {
      "date_times": formattedTimes,
    };

    var response = await postData("$ServerIP/api/protected/AddTherapistTimeBlocks", data);
    if (response["message"] == "Requested Successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointments successfully booked!")),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => RouterWidget()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book appointments.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Time Blocks")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Available Time Blocks for ${widget.therapist.name}",
              style: GoogleFonts.jost(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
                              children: [
                                Text(
                                  intl.DateFormat("yyyy/MM/dd").format(selectedDate),
                                  style: GoogleFonts.jost(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    DateTime? returnedDate = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
                                      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
                                    );
                                    if (returnedDate != null) {
                                      setState(() {
                                        selectedDate = returnedDate;
                                        loadBlocks();
    markBookedBlocks();
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.calendar_month_rounded),
                                ),
                              ],
                            ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2,
                mainAxisSpacing: 10,
              ),
              itemCount: timeBlocks.length,
              itemBuilder: (context, index) {
                var timeBlock = timeBlocks[index];
                return GestureDetector(
                  onTap: timeBlock.isAvailable ? () => toggleSelection(intl.DateFormat("yyyy/MM/dd & h:mm a").parse(timeBlock.date)) : null,
                  child: Card(
                    color: selectedTimeBlocks.contains(intl.DateFormat("yyyy/MM/dd & h:mm a").parse(timeBlock.date))
                        ? Colors.green
                        : (timeBlock.isAvailable ? Colors.white : Colors.grey),
                    elevation: 2,
                    child: Center(
                      child: Text(
                        intl.DateFormat("h:mm a").format(intl.DateFormat("yyyy/MM/dd & h:mm a").parse(timeBlock.date)),
                        style: TextStyle(
                          fontSize: 16,
                          color: timeBlock.isAvailable! ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: submitAppointments,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Block Selected", style: GoogleFonts.jost(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}