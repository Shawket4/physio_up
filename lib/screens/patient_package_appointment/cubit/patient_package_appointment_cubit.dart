import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/patient.dart';
import 'package:intl/intl.dart';
part 'patient_package_appointment_state.dart';

class PatientPackageAppointmentCubit extends Cubit<PatientPackageAppointmentState> {
  PatientPackageAppointmentCubit() : super(PatientPackageAppointmentInitial());

  static PatientPackageAppointmentCubit get(context) => BlocProvider.of(context);

  Future<List<Appointment>> fetchPatientCurrentPackage(int packageId) async {
    List<Appointment> appointments = [];
    try {
      final response = await postData(
        "$ServerIP/api/protected/FetchPackageAppointments",
        {"package_id": packageId},
      );
      for (var appointmentJSON in response.reversed.toList()) {
        Appointment appointment = Appointment.fromJson(appointmentJSON);
        appointments.add(appointment);
      }
    } catch (e) {
      print("Error fetching patient current package: $e");
    }
    return appointments;
  }

  // Helper function to group appointments by date
  Map<String, List<Appointment>> groupAppointmentsByDate(List<Appointment> appointments) {
    final Map<String, List<Appointment>> grouped = {};
    
    for (var appointment in appointments) {
      // Extract date part only from the dateTime string
      // Format is "yyyy/mm/dd & h:mm a"
      String dateOnly = appointment.dateTime.split(' & ')[0];
      
      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(appointment);
    }
    
    return grouped;
  }

  // Format date for display
  String formatDate(String dateString) {
    try {
      // Parse the date string with format "yyyy/mm/dd"
      final dateParts = dateString.split('/');
      if (dateParts.length == 3) {
        final DateTime date = DateTime(
          int.parse(dateParts[0]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[2]), // day
        );
        return DateFormat('EEEE, MMMM d, yyyy').format(date);
      }
      return dateString; // Return original if format doesn't match
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  // Extract and format time from dateTime string
  String extractTimeFromDateTime(String dateTime) {
    try {
      // Format is "yyyy/mm/dd & h:mm a"
      final parts = dateTime.split(' & ');
      if (parts.length == 2) {
        return parts[1]; // The time part is already in "h:mm a" format
      }
      return "Time not available";
    } catch (e) {
      return "Time not available";
    }
  }
}
