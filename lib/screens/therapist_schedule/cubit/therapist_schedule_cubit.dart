import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';

part 'therapist_schedule_state.dart';

class TherapistScheduleCubit extends Cubit<TherapistScheduleState> {
  TherapistScheduleCubit() : super(TherapistScheduleInitial());
  
  static TherapistScheduleCubit get(context) => BlocProvider.of(context);
  
  late Therapist therapist;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime firstVisibleDay = DateTime.now();
  DateTime lastVisibleDay = DateTime.now();
  Map<DateTime, List<TimeBlock>> bookedSlots = {};
  
  void init() {
    selectedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    focusedDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    calculateVisibleDays();
    fetchTherapist(); // Fetch data immediately
  }
  
  void calculateVisibleDays() {
    // Calculate visible range based on the focused day
    final DateTime firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final DateTime lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    
    firstVisibleDay = firstDay;
    lastVisibleDay = lastDay;
  }
  
  void selectDay(DateTime selected, DateTime focused) {
    selectedDay = DateTime(selected.year, selected.month, selected.day);
    focusedDay = focused;
    emit(TherapistScheduleLoaded(therapist)); // Re-emit loaded state to trigger UI update
  }
  
  void changePage(DateTime focused) {
    focusedDay = focused;
    calculateVisibleDays();
    fetchTherapist(); // Fetch new data when page changes
  }
  
  Future<Therapist> fetchTherapist() async {
    emit(TherapistScheduleLoading());
    try {
      dynamic response = await postData(
        "$ServerIP/api/protected/GetTherapistSchedule", {
          "start_date": DateFormat("yyyy/MM/dd").format(firstVisibleDay),
          "end_date": DateFormat("yyyy/MM/dd").format(lastVisibleDay)
        }
      );
      therapist = parseTherapist(response);
      processBookedSlots(therapist);
      emit(TherapistScheduleLoaded(therapist));
      return therapist;
    } catch (e) {
      emit(TherapistScheduleError("Failed to load schedule: $e"));
      throw Exception("Failed to load schedule: $e");
    }
  }
  
  void processBookedSlots(Therapist therapist) {
    Map<DateTime, List<TimeBlock>> newBookedSlots = {};
    for (var block in therapist.schedule?.timeBlocks ?? []) {
      try {
        String dateString = block.date.split(" & ")[0].trim();
        DateTime parsedDate = DateFormat("yyyy/MM/dd").parse(dateString);
        DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        newBookedSlots.putIfAbsent(normalizedDate, () => []).add(block);
      } catch (e) {
        print("Error parsing date: ${block.date} - $e");
      }
    }
    bookedSlots = newBookedSlots;
  }
  
  void refreshData() {
    fetchTherapist();
  }
  
  Future<void> markAsCompleted(int appointmentId) async {
    try {
     var response =  await postData(
        "$ServerIP/api/protected/MarkAppointmentAsCompleted",
        {"ID": appointmentId},
      ); 

      if (response is DioException) {
         emit(TherapistScheduleErrorMarkAsComplete("Error marking appointment as completed make sure the appointment has a set package:"));
         return;
      }

        print("object");
      for (var day in bookedSlots.entries) {
        for (var block in day.value) {
          if (block.appointment?.id == appointmentId) {
            block.appointment!.isCompleted = true;
            emit(TherapistScheduleLoaded(therapist)); // Re-emit loaded state
            break;
          }
        }
      }
    } on DioException catch (e) {
      emit(TherapistScheduleError("Error marking appointment as completed: $e"));
    }
  }

  Future<void> unmarkAsCompleted(int appointmentId) async {
    try {
      await postData(
        "$ServerIP/api/protected/UnmarkAppointmentAsCompleted",
        {"ID": appointmentId},
      );

      for (var day in bookedSlots.entries) {
        for (var block in day.value) {
          if (block.appointment?.id == appointmentId) {
            block.appointment!.isCompleted = false;
            emit(TherapistScheduleLoaded(therapist)); // Re-emit loaded state
            break;
          }
        }
      }
    } catch (e) {
      emit(TherapistScheduleError("Error unmarking appointment as completed: $e"));
    }
  }

  Future<void> deleteAppointment(int timeBlockId) async {
    try {
      await postData(
        "$ServerIP/api/protected/RemoveAppointmentSendMessage",
        {"ID": timeBlockId},
      );
    print("object");
      for (var entry in Map<DateTime, List<TimeBlock>>.from(bookedSlots).entries) {
        final date = entry.key;
        final blocks = entry.value;
        
        bookedSlots[date] = blocks.where((block) => block.id != timeBlockId).toList();
      }
      
      emit(TherapistScheduleLoaded(therapist)); // Re-emit loaded state
    } catch (e) {
      emit(TherapistScheduleError("Error deleting appointment: $e"));
    }
  }
}