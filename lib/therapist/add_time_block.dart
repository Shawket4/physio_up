import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
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
        date: intl.DateFormat("yyyy/MM/dd & h:mm a").format((DateTime(selectedDate.year, selectedDate.month, selectedDate.day, hour, 0))),
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
    if (selectedTimeBlocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one time block"),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    List<String> formattedTimes = selectedTimeBlocks.map(
      (dateTime) => intl.DateFormat("yyyy/MM/dd & h:mm a").format(dateTime),
    ).toList();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
      },
    );
    
    try {
      Map<String, dynamic> data = {
        "date_times": formattedTimes,
      };

      var response = await postData("$ServerIP/api/protected/AddTherapistTimeBlocks", data);
      
      // Close loading dialog
      Navigator.pop(context);
      
      if (response["message"] == "Requested Successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Time blocks successfully saved!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (_) => RouterWidget()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save time blocks."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: CustomAppBar(title: "Block Time Slots", actions: []),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Therapist info card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF011627),
                      child: Text(
                        widget.therapist.name.trim().split(' ').last[0].toUpperCase(),
                        style: GoogleFonts.jost(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.therapist.name,
                            style: GoogleFonts.jost(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF011627),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Select time blocks to mark as unavailable",
                            style: GoogleFonts.jost(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Date selection card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select Date",
                      style: GoogleFonts.jost(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        DateTime? returnedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (returnedDate != null) {
                          setState(() {
                            selectedDate = returnedDate;
                            loadBlocks();
                            markBookedBlocks();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              intl.DateFormat("EEEE, MMMM d, yyyy").format(selectedDate),
                              style: GoogleFonts.jost(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Icon(Icons.calendar_month_rounded, color: Color(0xFF011627)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time slots section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Time Slots",
                  style: GoogleFonts.jost(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    "${selectedTimeBlocks.length} selected",
                    style: GoogleFonts.jost(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Legend
            Row(
              children: [
                _buildLegendItem(Colors.white, "Available"),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.grey, "Already Booked"),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.green, "Selected"),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Time slots grid
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: timeBlocks.length,
                    itemBuilder: (context, index) {
                      var timeBlock = timeBlocks[index];
                      var dateTime = intl.DateFormat("yyyy/MM/dd & h:mm a").parse(timeBlock.date);
                      bool isSelected = selectedTimeBlocks.contains(dateTime);
                      bool isAvailable = timeBlock.isAvailable;
                      
                      return GestureDetector(
                        onTap: isAvailable ? () => toggleSelection(dateTime) : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : (isAvailable ? Colors.white : Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              intl.DateFormat("h:mm a").format(dateTime),
                              style: GoogleFonts.jost(
                                fontSize: 16,
                                color: isSelected || !isAvailable
                                    ? Colors.white
                                    : const Color(0xFF011627),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitAppointments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF011627),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Save Blocked Time Slots",
                      style: GoogleFonts.jost(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.jost(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}