import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/router.dart';
part 'add_time_block_state.dart';

class AddTimeBlockCubit extends Cubit<AddTimeBlockState> {
  AddTimeBlockCubit() : super(AddTimeBlockInitial());
  static AddTimeBlockCubit get(context) => BlocProvider.of(context);

  List<TimeBlock> timeBlocks = [];
  List<DateTime> selectedTimeBlocks = [];
  late DateTime selectedDate;

  void init(DateTime focusedDay,Therapist therapist) {
    selectedDate = focusedDay;
    loadBlocks();
    markBookedBlocks(therapist);
  }

  void loadBlocks() {
    timeBlocks.clear();
    for (int hour = 11; hour <= 23; hour++) {
      timeBlocks.add(TimeBlock(
        id: 0,
        date: intl.DateFormat("yyyy/MM/dd & h:mm a").format((DateTime(
            selectedDate.year, selectedDate.month, selectedDate.day, hour, 0))),
        isAvailable: true,
      ));
    }
  }

  void markBookedBlocks(Therapist therapist) {
    var bookedBlocks = therapist.schedule!.timeBlocks;
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
  
      if (selectedTimeBlocks.contains(time)) {
        selectedTimeBlocks.remove(time);
      } else {
        selectedTimeBlocks.add(time);
      }
    emit(ToggleSelection());
  }

  Future<void> submitAppointments(BuildContext context) async {
    if (selectedTimeBlocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one time block"),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    List<String> formattedTimes = selectedTimeBlocks
        .map(
          (dateTime) => intl.DateFormat("yyyy/MM/dd & h:mm a").format(dateTime),
        )
        .toList();

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

      var response = await postData(
          "$ServerIP/api/protected/AddTherapistTimeBlocks", data);

      // Close loading dialog
      Navigator.pop(context);

      if (response["message"] == "Requested Successfully") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Time blocks successfully saved!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => RouterWidget()));
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

  void setDate(DateTime returnedDate,Therapist therapist){
    
                                  selectedDate = returnedDate;
                                  loadBlocks();
                                  markBookedBlocks(therapist);
                                emit(SetDate(returnedDate));
  }

}
