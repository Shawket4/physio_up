// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:phsyio_up/dio_helper.dart';
// import 'package:phsyio_up/main.dart';
// import 'package:phsyio_up/screens/make_appointment.dart'; // Assuming this handles API requests

// class OTPVerificationScreen extends StatefulWidget {
//   final int appointmentId; // ID from previous screen
//   final String phoneNumber; // ID from previous screen
//   const OTPVerificationScreen({super.key, required this.appointmentId, required this.phoneNumber});

//   @override
//   State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
// }

// class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _verifyOTP() async {
//     if (_otpController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enter the OTP")),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await postData(
//         "$ServerIP/api/VerifyAppointmentRequestPhoneNo",
//         {
//           "ID": widget.appointmentId,
//           "otp": _otpController.text.trim(),
//         },
//       );
//       if (response is DioException) {
//          ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to verify OTP. Try again.")),
//       );
//       } else {

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Appointment Received!")),
//       );
//          Navigator.pop(context); 
//          Navigator.pop(context);
//          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MakeAppointmentScreen()));
//       }

   
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to verify OTP. Try again.")),
//       );
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Verify Phone Number")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Verification Code Sent To",
//               style: TextStyle(fontSize: 16, color: Colors.black54),
//             ),
//             SizedBox(height: 5),
//             Text(
//               widget.phoneNumber,
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 30),
//             TextField(
//               controller: _otpController,
//               keyboardType: TextInputType.number,
//               maxLength: 6,
//               decoration: InputDecoration(
//                 labelText: "Enter OTP",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.lock),
//               ),
//             ),
//             SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _verifyOTP,
//                 child: _isLoading
//                     ? CircularProgressIndicator(color: Colors.white)
//                     : Text("Submit"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
