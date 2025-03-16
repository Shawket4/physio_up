// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/screens/add_time_block/Ui/add_time_block.dart';
import 'package:phsyio_up/screens/therapist_schedule/cubit/therapist_schedule_cubit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';


class TherapistScheduleScreen extends StatefulWidget {
  const TherapistScheduleScreen({super.key});

  @override
  State<TherapistScheduleScreen> createState() =>
      _TherapistScheduleScreenState();
}

DateTime today = DateTime.now();
late Therapist therapist;

class _TherapistScheduleScreenState extends State<TherapistScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TherapistScheduleCubit()..calculateVisibleDays(),
      child: BlocBuilder<TherapistScheduleCubit, TherapistScheduleState>(
        builder: (context, state) {
          final cubit = TherapistScheduleCubit.get(context);
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MultiSelectAppointmentScreen(
                            therapist: therapist, focusedDay: cubit.focusedDay)));
              },
              backgroundColor: Colors.red,
              child: Icon(Icons.block, color: Colors.white),
              tooltip: "Block Time Slots",
              elevation: 4,
            ),
            // drawer: AppDrawer(),

            body: FutureBuilder<Therapist>(
              future: cubit.fetchTherapist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red.shade300,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Error: ${snapshot.error}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No schedule data available",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
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
                        firstDay:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: cubit.focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(cubit.selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          // Check if the selected day is within the current month
                          if (selectedDay.month == cubit.focusedDay.month) {
                           cubit.selectDay();
                          }
                        },
                        onPageChanged: (focusedDay) {
                         cubit.selectFocusDay();
                        },
                        eventLoader: (day) =>
                            cubit.bookedSlots[
                                DateTime(day.year, day.month, day.day)] ??
                            [],
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
                          weekendTextStyle:
                              TextStyle(color: Colors.red.shade300),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: Colors.blue.shade800,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Viewing: ${DateFormat('MMM d').format(cubit.firstVisibleDay)} - ${DateFormat('MMM d, yyyy').format(cubit.lastVisibleDay)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.event_note,
                                color: Colors.blue.shade800,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Appointments for ${DateFormat('MMMM d, yyyy').format(cubit.selectedDay)}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: cubit.bookedSlots[cubit.selectedDay]?.isEmpty ?? true
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
                              itemCount:
                                  cubit.bookedSlots[cubit.selectedDay]?.length ?? 0,
                              itemBuilder: (context, index) {
                                final block =
                                    cubit.bookedSlots[cubit.selectedDay]![index];
                                String time = block.date.split('&')[1].trim();
                                bool isBlocked =
                                    block.appointment?.patientName == "";
                                bool isCompleted =
                                    block.appointment?.isCompleted ?? false;

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
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
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
                                              color: isCompleted
                                                  ? Colors.green.shade50
                                                  : Colors.grey.shade100,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.done,
                                                color: isCompleted
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              tooltip: isCompleted
                                                  ? "Mark as incomplete"
                                                  : "Mark as completed",
                                              onPressed: () async => isCompleted
                                                  ? await cubit.unmarkAsCompleted(
                                                      block.appointment!.id)
                                                  : await cubit.markAsCompleted(
                                                      block.appointment!.id),
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
                                              onPressed: () =>
                                                  cubit.deleteAppointment(block.id),
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
                );
              },
            ),
          );
        },
      ),
    );
  }

  
}
