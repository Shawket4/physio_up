import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/models/therapist.dart' hide TimeBlock;
import 'package:phsyio_up/models/time_block.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:intl/intl.dart' as intl;
part 'create_patient_appointment_state.dart';

class CreatePatientAppointmentCubit extends Cubit<CreatePatientAppointmentState> {
  CreatePatientAppointmentCubit() : super(CreatePatientInitial());
  static CreatePatientAppointmentCubit get(context) => BlocProvider.of(context);

  bool isWorkingHoursLoaded = false;
  List<TimeBlock> timeBlocks = [];
  TimeBlock? selectedTimeBlock;
  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();
  List<dynamic> therapists = [];
  dynamic selectedTherapist;

  Future<String> loadTherapists() async {
    if (isWorkingHoursLoaded) {
      return "";
    }
    emit(loadTherapistsLoading());
    var response = await getData("$ServerIP/api/GetTherapists");
    therapists = response;
    if (therapists.isNotEmpty) {
      selectedTherapist = therapists[0];
      loadSchedule(
          selectedTherapist['ID'],
          therapists.firstWhere(
              (therapist) => therapist["ID"] == selectedTherapist['ID']));
    }
    emit(loadTherapistsSuccess(therapists));
    isWorkingHoursLoaded = true;
    return "";
  }

  Future<void> loadSchedule(int therapistId, dynamic therapist) async {
    emit(loadScheduleLoading());
    timeBlocks.clear();
    loadBlocks();
    var timeBlockResponse = therapist["schedule"]["time_blocks"];
    if (timeBlockResponse != null) {
      for (var timeBlock in timeBlockResponse) {
        var dateTime =
            intl.DateFormat("yyyy/MM/dd & h:mm a").parse(timeBlock["date"]);
        try {
          timeBlocks
              .firstWhere((element) => element.dateTime == dateTime)
              .isAvailable = false;
        } catch (e) {
          // Handle error if needed
        }
      }
    }
    isWorkingHoursLoaded = true;
    emit(loadScheduleSuccess(timeBlocks, therapist));
  }

  void loadBlocks() {
    for (int hour = 11; hour <= 23; hour++) {
      for (int minute = 0; minute < 60; minute += 60) {
        timeBlocks.add(TimeBlock(
          dateTime: DateTime(currentDate.year, currentDate.month,
              currentDate.day, hour, minute),
          isAvailable: true,
        ));
      }
    }
    selectedTimeBlock ??= timeBlocks[0];
  }

  void hasDate(DateTime returnedDate) {
    isWorkingHoursLoaded = false;
    currentDate = returnedDate;
    selectedDate = returnedDate;
    emit(HasDate());
  }

  void selectTherapist(Therapist therapist, int index) {
    selectedTherapist = therapist;
    selectedTimeBlock = timeBlocks[index];
    emit(SelectTherapist());
  }
}
