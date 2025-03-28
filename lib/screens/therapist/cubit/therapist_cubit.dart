import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:phsyio_up/main.dart';
import 'package:intl/intl.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/components/dio_helper.dart';
part 'therapist_state.dart';
DateTime today = DateTime.now();
class TherapistCubit extends Cubit<TherapistState> {
  TherapistCubit() : super(TherapistInitial());
  static TherapistCubit get(context) => BlocProvider.of(context);

  DateTime selectedDay = DateTime(today.year, today.month, today.day);
  Map<DateTime, List<TimeBlock>> bookedSlots = {};

  void init(Therapist therapist) {
    bookedSlots = fetchBookedSlots(therapist);
  }

  /// Extracts and correctly parses date/time blocks
  Map<DateTime, List<TimeBlock>> fetchBookedSlots(Therapist therapist) {
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
    emit(FetchBookedSlots());
    return bookedSlots;
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
        "$ServerIP/api/protected/RemoveAppointmentSendMessage",
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

    void selectDay(DateTime newDay) {
    selectedDay = DateTime(newDay.year, newDay.month, newDay.day);
    emit(SelectDay(selectedDay));
  }

  late Future<List<Therapist>> therapistsFuture;
  bool isRefreshing = false;

  void initList() {
    therapistsFuture = fetchData();
  }

  Future<void> refreshTherapists() async {
    
      isRefreshing = true;
    emit(RefreshTherapistsLoading());
    
    therapistsFuture = fetchData();
    
    
      isRefreshing = false;
    emit(RefreshTherapistsSuccess( await therapistsFuture));
  }

  Future<List<Therapist>> fetchData() async {
    List<Therapist> therapists = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/GetTherapists");
      therapists = parseTherapists(response);
    } catch (e) {
      print("Error fetching data: $e");
      // We'll handle this in the UI
    }
    return therapists;
  }

  
}
