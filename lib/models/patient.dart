class Patient {
  int id;
  String name;
  String phone;
  String gender;
  int age;
  double weight;
  double height;
  String diagnosis;
  String notes;
  List<Appointment> history;
  List<AppointmentRequest> requests;
  String otp;
  bool isVerified;

  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.diagnosis,
    required this.notes,
    required this.history,
    required this.requests,
    required this.otp,
    required this.isVerified,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['ID'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      weight: (json['weight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      diagnosis: json['diagnosis'],
      notes: json['notes'],
      history: (json['history'] as List<dynamic>?)?.map((e) => Appointment.fromJson(e)).toList() ?? [],
      requests: (json['requests'] as List<dynamic>?)?.map((e) => AppointmentRequest.fromJson(e)).toList() ?? [],
      otp: json['otp'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'diagnosis': diagnosis,
      'notes': notes,
      'history': history.map((e) => e.toJson()).toList(),
      'requests': requests.map((e) => e.toJson()).toList(),
      'otp': otp,
      'is_verified': isVerified,
    };
  }
}

class Appointment {
  int id;
  String dateTime;
  int timeBlockID;
  int therapistID;
  String therapistName;
  String patientName;
  int patientID;
  double price;
  bool isCompleted;
  bool isPaid;
  String paymentMethod;
  String notes;

  Appointment({
    required this.id,
    required this.dateTime,
    required this.timeBlockID,
    required this.therapistID,
    required this.therapistName,
    required this.patientName,
    required this.patientID,
    required this.price,
    required this.isCompleted,
    required this.isPaid,
    required this.paymentMethod,
    required this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? 0,
      dateTime: json['date_time'] ?? '',
      timeBlockID: json['time_block_id'] ?? 0,
      therapistID: json['therapist_id'] ?? 0,
      therapistName: json['therapist_name'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientID: json['patient_id'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      isPaid: json['is_paid'] ?? false,
      paymentMethod: json['payment_method'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_time': dateTime,
      'time_block_id': timeBlockID,
      'therapist_id': therapistID,
      'therapist_name': therapistName,
      'patient_name': patientName,
      'patient_id': patientID,
      'price': price,
      'is_completed': isCompleted,
      'is_paid': isPaid,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }
}

class AppointmentRequest {
  int id;
  String dateTime;
  int therapistID;
  String therapistName;
  String patientName;
  int patientID;
  String phoneNumber;

  AppointmentRequest({
    required this.id,
    required this.dateTime,
    required this.therapistID,
    required this.therapistName,
    required this.patientName,
    required this.patientID,
    required this.phoneNumber,
  });

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    return AppointmentRequest(
      id: json['id'] ?? 0,
      dateTime: json['date_time'] ?? '',
      therapistID: json['therapist_id'] ?? 0,
      therapistName: json['therapist_name'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientID: json['patient_id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_time': dateTime,
      'therapist_id': therapistID,
      'therapist_name': therapistName,
      'patient_name': patientName,
      'patient_id': patientID,
      'phone_number': phoneNumber,
    };
  }
}

List<Patient> parsePatients(dynamic responseBody) {
  return responseBody.map<Patient>((json) => Patient.fromJson(json)).toList();
}

Patient parsePatient(dynamic responseBody) {
  return Patient.fromJson(responseBody);
}