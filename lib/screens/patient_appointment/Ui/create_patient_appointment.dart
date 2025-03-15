// ignore_for_file: deprecated_member_use
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/components/dialog.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/screens/patient_appointment/cubit/create_patient_appointment_cubit.dart';

class MakeAppointmentScreen extends StatefulWidget {
  final int patientID;

  const MakeAppointmentScreen({super.key, required this.patientID});

  @override
  State<MakeAppointmentScreen> createState() => MakeAppointmentScreenState();
}

class MakeAppointmentScreenState extends State<MakeAppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePatientAppointmentCubit(),
      child: BlocBuilder<CreatePatientAppointmentCubit, CreatePatientAppointmentState>(
        builder: (context, state) {
          CreatePatientAppointmentCubit cubit = CreatePatientAppointmentCubit.get(context);
          return Scaffold(
            backgroundColor: const Color(0xFFF2F5F9),
            appBar: CustomAppBar(title: "Schedule Appointment", actions: []),
            body: FutureBuilder(
              future: cubit.loadTherapists(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                                        backgroundColor:
                                            const Color(0xFF011627),
                                        child: Text(
                                          cubit.selectedTherapist!.name
                                              .split(' ')
                                              .last[0]
                                              .toUpperCase(),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cubit.selectedTherapist!.name,
                                              style: GoogleFonts.jost(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF011627),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Selected therapist",
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
                                    initialDate: cubit.currentDate,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 90)),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (returnedDate != null) {
                                    cubit.hasDate(returnedDate);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        intl.DateFormat("EEEE, MMMM d, yyyy")
                                            .format(cubit.currentDate),
                                        style: GoogleFonts.jost(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Icon(Icons.calendar_month_rounded,
                                          color: Color(0xFF011627)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const SizedBox(height: 16),

                      // Time slots section
                      Text(
                        "Available Time Slots",
                        style: GoogleFonts.jost(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) {
                                List<dynamic> availableTherapists =
                                    cubit.therapists.where((therapist) {
                                  var bookedTimes = therapist.schedule!
                                       .timeBlocks;
                                  DateTime selectedTime =
                                      cubit.timeBlocks[index].dateTime!;

                                  bool isBooked = bookedTimes.any((block) {
                                    DateTime bookedTime =
                                        intl.DateFormat("yyyy/MM/dd & h:mm a")
                                            .parse(block.date);
                                    return bookedTime == selectedTime;
                                  });

                                  return !isBooked;
                                }).toList();

                                bool isSelected =
                                    cubit.selectedTimeBlock!.dateTime! ==
                                        cubit.timeBlocks[index].dateTime;
                                bool isAvailable =
                                    availableTherapists.isNotEmpty;

                                return GestureDetector(
                                  onTap: isAvailable
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  "Available Therapists",
                                                  style: GoogleFonts.jost(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                content: SizedBox(
                                                  width: double.maxFinite,
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    children:
                                                        availableTherapists
                                                            .map((therapist) {
                                                      return ListTile(
                                                        leading: CircleAvatar(
                                                          backgroundColor:
                                                              Color(0xFF011627),
                                                          child: Text(
                                                            therapist.name
                                                                .split(' ')
                                                                .last[0]
                                                                .toUpperCase(),
                                                            style: GoogleFonts
                                                                .jost(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        title: Text(
                                                          therapist.name,
                                                          style:
                                                              GoogleFonts.jost(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        onTap: () {
                                                         cubit.selectTherapist(therapist, index);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      "Cancel",
                                                      style: GoogleFonts.jost(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : isAvailable
                                              ? Colors.white
                                              : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        intl.DateFormat("h:mm a").format(
                                            cubit.timeBlocks[index].dateTime!),
                                        style: GoogleFonts.jost(
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : isAvailable
                                                  ? const Color(0xFF011627)
                                                  : Colors.grey,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: cubit.timeBlocks.length,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Book button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            showLoadingDialog(context);
                            try {
                              DateTime finalDateTime = DateTime(
                                cubit.selectedDate.year,
                                cubit.selectedDate.month,
                                cubit.selectedDate.day,
                                cubit.selectedTimeBlock!.dateTime!.hour,
                                cubit.selectedTimeBlock!.dateTime!.minute,
                              );
                              Map<String, dynamic> data = {
                                "date_time":
                                    intl.DateFormat("yyyy/MM/dd & h:mm a")
                                        .format(finalDateTime),
                                "therapist_id": cubit.selectedTherapist!.id,
                                "patient_id": widget.patientID,
                              };
                              var response = await postData(
                                      "$ServerIP/api/RequestAppointment", data)
                                  .timeout(const Duration(seconds: 5));
                              if (response["message"] ==
                                  "Requested Successfully") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Appointment scheduled successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => MainWidget()));
                              }
                            } catch (e) {
                              showErrorDialog(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF011627),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Confirm Appointment",
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
