import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/screens/therapist_schedule/therapist_schedule.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/main.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/components/dio_helper.dart';
part 'therapist_schedule_state.dart';

class TherapistScheduleCubit extends Cubit<TherapistScheduleState> {
  TherapistScheduleCubit() : super(TherapistScheduleInitial());
  static TherapistScheduleCubit get(context) => BlocProvider.of(context);

  DateTime selectedDay = DateTime(today.year, today.month, today.day);
  DateTime focusedDay = DateTime(today.year, today.month, today.day);
  Map<DateTime, List<TimeBlock>> bookedSlots = {};

  // Track first and last visible days
  late DateTime firstVisibleDay;
  late DateTime lastVisibleDay;

  void calculateVisibleDays() {
    // Calculate visible range based on the focused day
    // This will depend on the calendar format (month, week, etc.)
    final DateTime firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final DateTime lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    firstVisibleDay = firstDay;
    lastVisibleDay = lastDay;
    emit(CalculateVisibleDays());
  }

  Future<Therapist> fetchTherapist() async {
    // Now also passing the visible date range to the API
    dynamic response =
        await postData("$ServerIP/api/protected/GetTherapistSchedule", {
      "start_date": DateFormat("yyyy/MM/dd").format(firstVisibleDay),
      "end_date": DateFormat("yyyy/MM/dd").format(lastVisibleDay)
    });
    therapist = parseTherapist(response);
    processBookedSlots(therapist);
    return therapist;
  }

  void processBookedSlots(Therapist therapist) {
    Map<DateTime, List<TimeBlock>> bookedSlots = {};
    for (var block in therapist.schedule?.timeBlocks ?? []) {
      try {
        String dateString = block.date.split(" & ")[0].trim();
        DateTime parsedDate = DateFormat("yyyy/MM/dd").parse(dateString);
        DateTime normalizedDate =
            DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        bookedSlots.putIfAbsent(normalizedDate, () => []).add(block);
      } catch (e) {
        print("Error parsing date: ${block.date} - $e");
      }
    }
    bookedSlots = bookedSlots;
  }

  void selectDay() {
    selectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    focusedDay = focusedDay;
    emit(SelectDay());
  }

  void selectFocusDay() {
    focusedDay = focusedDay;
    emit(SelectFocusDay());
    calculateVisibleDays();
    emit(SelectFocusDay());
  }

  Future<void> markAsCompleted(int appointmentId) async {
    try {
      await postData(
        "$ServerIP/api/protected/MarkAppointmentAsCompleted",
        {"ID": appointmentId},
      );

      for (var day in bookedSlots.values) {
        for (var block in day) {
          if (block.appointment!.id == appointmentId) {
            bookedSlots.values
                .firstWhere((element) => element == day)
                .firstWhere((block2) => block2 == block)
                .appointment!
                .isCompleted = true;

           emit(MarkAsCompleted());
          }
        }
      }
    } catch (e) {
      print("Error updating price: $e");
    }
  }

  Future<void> unmarkAsCompleted(int appointmentId) async {
    try {
      await postData(
        "$ServerIP/api/protected/UnmarkAppointmentAsCompleted",
        {"ID": appointmentId},
      );

      for (var day in bookedSlots.values) {
        for (var block in day) {
          if (block.appointment!.id == appointmentId) {
            bookedSlots.values
                .firstWhere((element) => element == day)
                .firstWhere((block2) => block2 == block)
                .appointment!
                .isCompleted = false;

            emit(UnmarkAsCompleted());
          }
        }
      }
    } catch (e) {
      print("Error updating price: $e");
    }
  }

  Future<void> deleteAppointment(int timeBlockId) async {
    try {
      await postData(
        "$ServerIP/api/protected/RemoveAppointment",
        {"ID": timeBlockId},
      );

      for (var day in bookedSlots.values) {
        for (var block in day) {
          if (block.id == timeBlockId) {
           bookedSlots.values
                .firstWhere((element) => element == day)
                .remove(block);
            emit(DeleteAppointment());
          }
        }
      }
    } catch (e) {
      print("Error deleting appointment: $e");
    }
  }
}
