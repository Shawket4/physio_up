import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/screens/patient/Ui/patients_list.dart';
import 'package:phsyio_up/screens/referral/Ui/referral_list_screen.dart';
import 'package:phsyio_up/screens/treatment_packages/Ui/treatment_list_screen.dart';
import 'package:phsyio_up/screens/appointment_request/Ui/appointment_requests.dart';
import 'package:phsyio_up/secretary/date_dialog.dart';
import 'package:phsyio_up/secretary/therapists.dart';
import 'package:phsyio_up/therapist/therapist_schedule.dart';



class RouterWidget extends StatefulWidget {
  const RouterWidget({super.key});

  @override
  State<RouterWidget> createState() => _RouterWidgetState();
}

class _RouterWidgetState extends State<RouterWidget> {
  int _selectedIndex = 0;
  late List<NavigationItem> _navigationItems;
  late Widget _currentScreen;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  @override
  void initState() {
    super.initState();
    _buildNavigationItems();
    _currentScreen = _navigationItems[0].screen;
  }
  
  void _buildNavigationItems() {
    _navigationItems = [
      NavigationItem(
        title: 'Requests',
        icon: Icons.home_rounded,
        screen: AppointmentRequestScreen(),
      ),
      if (userInfo.permission == 2)
        NavigationItem(
          title: 'My Schedule',
          icon: Icons.calendar_month_rounded,
          screen: TherapistScheduleScreen(),
        ),
      NavigationItem(
        title: 'Therapists',
        icon: Icons.person_rounded,
        screen: TherapistListScreen(),
      ),
      NavigationItem(
        title: 'Patients',
        icon: Icons.people_alt_rounded,
        screen: PatientListScreen(),
      ),
      NavigationItem(
        title: 'Referrals',
        icon: Icons.swap_vertical_circle_rounded,
        screen: ReferralListScreen(),
      ),
      NavigationItem(
        title: 'Packages',
        icon: Icons.medical_services_rounded,
        screen: TreatmentListScreen(),
      ),
    ];
  }

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _currentScreen = _navigationItems[index].screen;
    });
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _exportSales() async {
    _scaffoldKey.currentState?.closeDrawer();
    
    // Show the date range picker dialog
    final selectedDates = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (BuildContext context) {
        return DateRangePickerDialog2();
      },
    );

    if (selectedDates == null || 
        selectedDates['dateFrom'] == null || 
        selectedDates['dateTo'] == null) {
      return;
    }
    
    try {
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
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Sales_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Send the selected dates to the API
      await downloadDataPost(
        "$ServerIP/api/protected/ExportSalesTable",
        filePath,
        {
          'date_from': DateFormat('yyyy-MM-dd').format(selectedDates['dateFrom']!),
          'date_to': DateFormat('yyyy-MM-dd').format(selectedDates['dateTo']!),
        },
      );

      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sales data exported to $fileName'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Open the downloaded file
      final result = await OpenFile.open(filePath);
      
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file: ${result.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Auto-delete file after a delay
        Future.delayed(const Duration(minutes: 5), () async {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        });
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting sales data: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
        _currentScreen = _navigationItems[0].screen;
      });
      return false;
    }
    return true;
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: GoogleFonts.jost(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: GoogleFonts.jost(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.jost(),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Logout(context);
              },
              child: Text(
                'Logout',
                style: GoogleFonts.jost(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(title: _navigationItems[_selectedIndex].title, leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ), actions: <Widget>[
            if (userInfo.permission == 2)
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'My Schedule',
                onPressed: () => _navigateToIndex(
                  _navigationItems.indexWhere((item) => item.title == 'My Schedule')
                ),
              ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],),
        drawer: AppDrawer(),
        body: _currentScreen,
      ),
    );
  }

  Widget AppDrawer() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            width: double.infinity,
            color: primaryColor.withOpacity(0.05),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: 180,
                  child: Image.asset(
                    "assets/images/Logo_Dark.png",
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  userInfo.permission == 2 ? "Therapist" : "Clinic",
                  style: GoogleFonts.jost(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ..._navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return ListTile(
                    leading: Icon(
                      item.icon,
                      color: _selectedIndex == index 
                          ? primaryColor 
                          : Colors.black54,
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.jost(
                        fontSize: 18,
                        fontWeight: _selectedIndex == index 
                            ? FontWeight.w700 
                            : FontWeight.w500,
                        color: _selectedIndex == index 
                            ? primaryColor 
                            : Colors.black87,
                      ),
                    ),
                    selected: _selectedIndex == index,
                    selectedTileColor: primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () => _navigateToIndex(index),
                  );
                }).toList(),
                
                const Divider(height: 32, thickness: 1),
                
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: Text(
                    "Export Sales",
                    style: GoogleFonts.jost(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: _exportSales,
                ),
                
                ListTile(
                  leading: const Icon(
                    Icons.logout_outlined,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Logout",
                    style: GoogleFonts.jost(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "PhysioUp v1.0.0",
              style: GoogleFonts.jost(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final Widget screen;
  
  NavigationItem({
    required this.title,
    required this.icon,
    required this.screen,
  });
}