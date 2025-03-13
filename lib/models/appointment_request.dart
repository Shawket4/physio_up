import 'package:intl/intl.dart';
import 'package:phsyio_up/models/time_block.dart';

class AppointmentRequest {
  int ID = 0;
  TimeBlock timeBlock = TimeBlock();
  int TherapistID = 0;
  String TherapistName = "";
  String PatientName = "";
  String PackageDescriptionRequested = "";
  int PatientID = 0;


  AppointmentRequest({
    required this.ID,
    required this.timeBlock,
    required this.TherapistID,
    required this.TherapistName,
    required this.PatientName,
    required this.PatientID,
    required this.PackageDescriptionRequested,
  });

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    var dateTime =
            DateFormat("yyyy/MM/dd & h:mm a").parse(json["date_time"]);
    return AppointmentRequest(
      ID: json['ID'] ?? 0,
      timeBlock: TimeBlock(dateTime: dateTime),
      TherapistID: json['therapist_id'] ?? 0,
      TherapistName: json['therapist_name'] ?? '',
      PatientName: json['patient_name'] ?? '',
      PatientID: json['patient_id'] ?? 0,
      PackageDescriptionRequested: json['super_treatment_plan_description'] ?? '',
    );
  }
}

