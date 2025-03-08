import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/screens/patients.dart';
import 'package:phsyio_up/screens/referral/referral_list_screen.dart';
import 'package:phsyio_up/screens/treatment_packages/treatment_list_screen.dart';
import 'package:phsyio_up/secretary/appointment_requests.dart';
import 'package:phsyio_up/secretary/date_dialog.dart';
import 'package:phsyio_up/secretary/therapists.dart';
import 'package:phsyio_up/therapist/therapist_schedule.dart';

class RouterWidget extends StatefulWidget {
  const RouterWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RouterWidgetState createState() => _RouterWidgetState();
}

class _RouterWidgetState extends State<RouterWidget> {
  Widget _currentScreen = AppointmentRequestScreen(); // Default screen

  void _navigateTo(Widget screen) {
    setState(() {
      _currentScreen = screen;
    });
    Navigator.of(context).pop(); // Close the drawer after navigation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentScreen,
    );
  }
}

// Custom Drawer Widget
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final routerState = context.findAncestorStateOfType<_RouterWidgetState>();
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
                    height: 80,
                  ),
          Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      width: 180,
                      child: Image.asset(
                        "assets/images/Logo_Dark.png",
                      ),
                    ),
                  ),
          const SizedBox(
            height: 15,
          ),
                    userInfo.permission == 2 ?
          ListTile(
            leading: Icon(Icons.calendar_month, ),
            title: Text("My Schedule", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () {routerState?._navigateTo(TherapistScheduleScreen());}
          ) : Container(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text("Requests", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () => routerState?._navigateTo(AppointmentRequestScreen()),
          ),
          ListTile(
            leading: Icon(Icons.person, ),
            title: Text("Therapists", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () {routerState?._navigateTo(TherapistListScreen());}
          ),
           ListTile(
            leading: Icon(Icons.person, ),
            title: Text("Patients", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () {routerState?._navigateTo(PatientListScreen());}
          ),

        ListTile(
            leading: Icon(Icons.swap_vertical_circle_sharp, ),
            title: Text("Referrals", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () {routerState?._navigateTo(ReferralListScreen());}
          ),

          ListTile(
            leading: Icon(Icons.archive, ),
            title: Text("Packages", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () {routerState?._navigateTo(TreatmentListScreen());}
          ),

          ListTile(
            leading: Icon(Icons.book, ),
            title: Text("Export Sales", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () async {
  // Show the date range picker dialog
  final selectedDates = await showDialog<Map<String, DateTime?>>(
    context: context,
    builder: (BuildContext context) {
      return DateRangePickerDialog2();
    },
  );

  // Check if dates were selected
  if (selectedDates != null && selectedDates['dateFrom'] != null && selectedDates['dateTo'] != null) {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Sales.xlsx';

    // Send the selected dates to the API
    downloadDataPost(
      "$ServerIP/api/protected/ExportSalesTable",
      filePath,
      {
        'date_from': DateFormat('yyyy-MM-dd').format(selectedDates['dateFrom']!),
        'date_to': DateFormat('yyyy-MM-dd').format(selectedDates['dateTo']!),
      },
    );

    // Open the downloaded file
    final result = await OpenFile.open(filePath);
    
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open file: ${result.message}')),
      );
    }
  }
},
          
          ),

           ListTile(
            leading: Icon(Icons.logout_outlined, ),
            title: Text("Logout", style: GoogleFonts.jost(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,

                                      ),),
            onTap: () {
              Logout(context);
              }
          ),
        ],
      ),
    );
  }
}
