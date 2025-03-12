import 'dart:convert';

class Therapist {
  final int id;
  final String name;
  final String phone;
  final String photoUrl;
  final bool isDemo;
  final bool isFrozen;
  final Schedule? schedule;

  Therapist({
    required this.id,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.isDemo,
    required this.isFrozen,
    this.schedule,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) {

    return Therapist(
      id: json['ID'],
      name: json['name'],
      phone: json['phone'] ?? "",
      photoUrl: json['photo_url'] ?? "",
      isDemo: json['is_demo'] ?? false,
      isFrozen: json['is_frozen'] ?? false,
      schedule:
          json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    );
  }
}

class Schedule {
  final int id;
  final List<TimeBlock> timeBlocks;

  Schedule({
    required this.id,
    required this.timeBlocks,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['ID'],
      timeBlocks: (json['time_blocks'] as List?)
              ?.map((item) => TimeBlock.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TimeBlock {
  final int id;
  final String date;
  bool isAvailable;
  final Appointment? appointment;

  TimeBlock({
    required this.id,
    required this.date,
    required this.isAvailable,
    this.appointment,
  });

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      id: json['ID'],
      date: json['date'],
      isAvailable: json['is_available'] ?? false,
      appointment:
          json['appointment'] != null ? Appointment.fromJson(json['appointment']) : null,
    );
  }
}

class Appointment {
  final int id;
  final String dateTime;
  final String patientName;
  final int patientID;
  final String therapistName;
  final int price;
  bool isCompleted;
  bool isPaid;
  final String notes;

  Appointment( {
    required this.id,
    required this.dateTime,
    required this.patientName,
    required this.price,
    required this.isCompleted,
    required this.isPaid,
    required this.notes,
    required this.therapistName,
    required this.patientID,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['ID'],
      dateTime: json['date_time'],
      patientName: json['patient_name'],
      price: json['price'],
      isCompleted: json['is_completed'] ?? false,
      isPaid: json['is_paid'] ?? false,
      notes: json['notes'] ?? "",
      therapistName: json["therapist_name"],
      patientID: json["patient_id"],
    );
  }
}

// Function to parse the JSON response into a list of therapists
List<Therapist> parseTherapists(dynamic responseBody) {
List<Therapist> output = responseBody.map<Therapist>((json) => Therapist.fromJson(json)).toList();
  return output;
}

Therapist parseTherapist(dynamic responseBody) {
Therapist output = Therapist.fromJson(responseBody);
  return output;
}
