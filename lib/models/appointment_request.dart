import 'package:phsyio_up/models/time_block.dart';

class AppointmentRequest {
  int ID = 0;
  TimeBlock timeBlock = TimeBlock();
  int TherapistID = 0;
  String TherapistName = "";
  String PatientName = "";
  String PackageDescriptionRequested = "";
  int PatientID = 0;
}
