// // ignore_for_file: use_build_context_synchronously, avoid_print

// import 'package:phsyio_up/components/dialog.dart';
// import 'package:phsyio_up/dio_helper.dart';
// import 'package:phsyio_up/main.dart';
// import 'package:phsyio_up/models/time_block.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:phsyio_up/screens/confirm_phone_otp.dart';


// class MakeAppointmentScreen extends StatefulWidget {
//   const MakeAppointmentScreen({super.key});
//   @override
//   State<MakeAppointmentScreen> createState() => MakeAppointmentScreenState();
// }

// class MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
//   bool isWorkingHoursLoaded = false;
//   List<TimeBlock> timeBlocks = [];
//   TimeBlock? selectedTimeBlock;
//   DateTime selectedDate = DateTime.now();
//   DateTime currentDate = DateTime.now();
//   List<dynamic> therapists = [];
//   dynamic selectedTherapist;
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneNumber = TextEditingController();
//   TextEditingController patientID = TextEditingController();
//   bool isExisting = true;
//   @override
//   void initState() {
//     isWorkingHoursLoaded = false;
//     super.initState();
//   }

//   Future<String> loadTherapists() async {
//     if (isWorkingHoursLoaded) {
//       return "";
//     }
//     var response = await getData("$ServerIP/api/GetTherapists");
//     setState(() {
//       therapists = response;
//       if (therapists.isNotEmpty) {
//         // print(response);
//         selectedTherapist = therapists[0];
//         loadSchedule(selectedTherapist['ID'], therapists.firstWhere((therapist) => therapist["ID"] == selectedTherapist['ID']));
//       }
//     });
//     isWorkingHoursLoaded = true;
//      await showDialog(context: context, barrierDismissible: false, builder: (context) {
//       return AlertDialog(
//         content: SizedBox(
//           width: 200,
//           height: 200,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(onPressed: () {
//                 Navigator.pop(context);
//                 setState(() {
                  
//                 });
//               }, child: Text("Existing", style: TextStyle(fontSize: 18),)),
//               SizedBox(width: 30,),
//               ElevatedButton(onPressed: () {
//                 isExisting = false;
//                 Navigator.pop(context);
//                 setState(() {
                  
//                 });
//               }, child: Text("New", style: TextStyle(fontSize: 18),)),
//             ],
//           ),
//         ),
//       );
//     });
//     return "";
//   }

//   Future<void> loadSchedule(int therapistId, dynamic therapist) async {
//     setState(() {
//       timeBlocks.clear();
//       loadBlocks();
//       var timeBlockResponse = therapist["schedule"]["time_blocks"];
//       if (timeBlockResponse != null) {
//         for (var timeBlock in timeBlockResponse) {
//           var dateTime = intl.DateFormat("yyyy/MM/dd & h:mm a").parse(timeBlock["date"]);
//           try {
//             timeBlocks.firstWhere((element) => element.dateTime == dateTime).isAvailable = false;
//           } catch (e) {
//             // Handle error if needed
//           }
//         }
//       }
//       isWorkingHoursLoaded = true;
//     });
//   }

//   void loadBlocks() {
//     for (int hour = 11; hour <= 22; hour++) {
//       for (int minute = 0; minute < 60; minute += 60) {
//         timeBlocks.add(TimeBlock(
//           dateTime: DateTime(currentDate.year, currentDate.month, currentDate.day, hour, minute),
//           isAvailable: true,
//         ));
//       }
//     }
//     selectedTimeBlock ??= timeBlocks[0];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F5F9),
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: const Color(0xFF011627),
//         title: const Text(
//           "Make Appointment",
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: FutureBuilder(
//         future: loadTherapists(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: Lottie.asset(
//                 "assets/lottie/Loading.json",
//                 height: 200,
//                 width: 200,
//               ),
//             );
//           }
//           return SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 const SizedBox(height: 15.0),
//                 SizedBox(
//                   width: double.infinity,
//                   height: MediaQuery.of(context).size.height / 1.5,
//                   child: Card(
//                     color: const Color(0xFFF1F3FF),
//                     elevation: 5,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
              
//                         Align(
//                           alignment: Alignment.centerLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   intl.DateFormat("yyyy/MM/dd").format(currentDate),
//                                   style: GoogleFonts.jost(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 IconButton(
//                                   onPressed: () async {
//                                     DateTime? returnedDate = await showDatePicker(
//                                       context: context,
//                                       initialDate: currentDate,
//                                       firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
//                                       lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
//                                     );
//                                     if (returnedDate != null) {
//                                       setState(() {
//                                         isWorkingHoursLoaded = false;
//                                         currentDate = returnedDate;
//                                         selectedDate = returnedDate;
//                                       });
//                                     }
//                                   },
//                                   icon: const Icon(Icons.calendar_month_rounded),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                        Text("Therapist: ${selectedTherapist["name"]}", style: TextStyle(fontSize: 18),),
//                         SizedBox(height: 10,),
//                         Expanded(
//                           child: GridView.builder(
//                             shrinkWrap: true,
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               childAspectRatio: 2,
//                               mainAxisSpacing: 10,
//                             ),
//                             itemBuilder: (context, index) { 
//                               List<dynamic> availableTherapists = therapists.where((therapist) {
//       var bookedTimes = therapist["schedule"]["time_blocks"] ?? [];
//       DateTime selectedTime = timeBlocks[index].dateTime!;
      
//       // Check if the selected time is booked
//       bool isBooked = bookedTimes.any((block) {
//         DateTime bookedTime = intl.DateFormat("yyyy/MM/dd & h:mm a").parse(block["date"]);
//         return bookedTime == selectedTime;
//       });

//       return !isBooked; // Return therapists who are NOT booked at this time
//     }).toList();
//                               return Opacity(
//                               opacity: availableTherapists.isEmpty ? 0.4 : 1,
//                               child: GestureDetector(
//                                 onTap: () {

//     showDialog(
//       barrierDismissible: false,
//   context: context,
//   builder: (context) {
//     // Filter therapists based on their availability at the selected time

//     return AlertDialog(
//       title: const Text("Available Therapists"),
//       content: SizedBox(
//         width: double.maxFinite,
//         child: availableTherapists.isNotEmpty
//             ? ListView(
//                 shrinkWrap: true,
//                 children: availableTherapists.map((therapist) {
//                   return ListTile(
//                     title: Text(therapist["name"]),
//                     onTap: () {
//                       setState(() {
//                         selectedTherapist = therapist;
//                         selectedTimeBlock = timeBlocks[index];
//                       });
//                       Navigator.pop(context); // Close dialog
//                     },
//                   );
//                 }).toList(),
//               )
//             : const Text("No available therapists for this time slot."),
//       ),
//     );
//   },
// );                               
// },
//                                 child: SizedBox(
//                                   height: 50,
//                                   child: Card(
//                                     color: selectedTimeBlock!.dateTime! == timeBlocks[index].dateTime
//                                         ? Theme.of(context).primaryColor
//                                         : const Color(0xFFFEFEFE),
//                                     elevation: 2,
//                                     child: Center(
//                                       child: Text(
//                                         intl.DateFormat("h:mm a").format(timeBlocks[index].dateTime!),
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           color: selectedTimeBlock!.dateTime! == timeBlocks[index].dateTime
//                                               ? Colors.white
//                                               : null,
//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                             },
//                             itemCount: timeBlocks.length,
                            
//                           ),
//                         ),
//                         isExisting ? SizedBox(height: 0,) :
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           child: TextField(
//                             autocorrect: false,
//                             controller: nameController,
//                             decoration: const InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFF011627),
//                                   width: 2.0,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(),
//                               labelText: 'Name',
//                               labelStyle: TextStyle(
//                                 color: Color(0xFF011627),
//                               ),
//                             ),
//                           ),
//                         ),
//                          isExisting ? SizedBox() :
//                         Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           child: TextField(
//                             autocorrect: false,
//                             controller: phoneNumber,
//                             decoration: const InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFF011627),
//                                   width: 2.0,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(),
//                               labelText: 'Phone Number',
//                               labelStyle: TextStyle(
//                                 color: Color(0xFF011627),
//                               ),
//                             ),
//                           ),
//                         ),
//                         !isExisting ? SizedBox() : Container(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           child: TextField(
//                             autocorrect: false,
//                             controller: patientID,
//                             decoration: const InputDecoration(
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFF011627),
//                                   width: 2.0,
//                                 ),
//                               ),
//                               border: OutlineInputBorder(),
//                               labelText: 'ID',
//                               labelStyle: TextStyle(
//                                 color: Color(0xFF011627),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     showLoadingDialog(context);
//                     try {
//                       DateTime finalDateTime = DateTime(
//                         selectedDate.year,
//                         selectedDate.month,
//                         selectedDate.day,
//                         selectedTimeBlock!.dateTime!.hour,
//                         selectedTimeBlock!.dateTime!.minute,
//                       );
//                       Map<String, dynamic> data = {
//                         "date_time": intl.DateFormat("yyyy/MM/dd & h:mm a").format(finalDateTime),
//                         "patient_name": nameController.text,
//                         "therapist_id": selectedTherapist['ID'],
//                         "phone_number": phoneNumber.text,
//                         "patient_id": isExisting ? int.parse(patientID.text) : 0,
//                       };
//                       var response = await postData("$ServerIP/api/RequestAppointment", data)
//                           .timeout(const Duration(seconds: 5));
//                       if (response["message"] == "Requested Successfully") {
//                         if (isExisting) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Appointment Received!")),
//       );
//                         } else {
//                         Navigator.push(context, MaterialPageRoute(builder: (_) => OTPVerificationScreen(appointmentId: response["appointment_id"], phoneNumber: phoneNumber.text)));
//                         }
//                         // showSuccessDialog(context);
//                       }
//                     } catch (e) {
//                       showErrorDialog(context);
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           "Book",
//                           style: GoogleFonts.jost(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         const Icon(
//                           Icons.book_rounded,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }