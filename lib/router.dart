// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/screens/patient/Ui/patients_list.dart';
import 'package:phsyio_up/screens/referral/Ui/referral_list_screen.dart';
import 'package:phsyio_up/screens/secretary/Ui/date_dialog.dart';
import 'package:phsyio_up/screens/secretary/Ui/therapists.dart';
import 'package:phsyio_up/screens/therapist/Ui/therapist_schedule.dart';
import 'package:phsyio_up/screens/treatment_packages/Ui/treatment_list_screen.dart';
import 'package:phsyio_up/screens/appointment_request/Ui/appointment_requests.dart';

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
  List<BottomNavigationItem> _bottomNavItems = [];

  @override
  void initState() {
    super.initState();
    _initializeBottomNavigation();
    _buildNavigationItems();
    _currentScreen = _navigationItems[0].screen;
  }

  void _initializeBottomNavigation() {
    _bottomNavItems = [
      BottomNavigationItem(
        icon: Icons.home_rounded,
        label: 'Requests',
        screen: AppointmentRequestScreen(),
      ),
      if (userInfo.permission == 2)
        BottomNavigationItem(
          icon: Icons.calendar_month_rounded,
          label: 'My Schedule',
          screen: TherapistScheduleScreen(),
        ),
      BottomNavigationItem(
        icon: Icons.person_rounded,
        label: 'Therapists',
        screen: TherapistListScreen(),
      ),
      BottomNavigationItem(
        icon: Icons.people_alt_rounded,
        label: 'Patients',
        screen: PatientListScreen(),
      ),
    ];
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      _currentScreen = _bottomNavItems[index].screen;
    });
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
      final fileName =
          'Sales_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';

      // Send the selected dates to the API
      await downloadDataPost(
        "$ServerIP/api/protected/ExportSalesTable",
        filePath,
        {
          'date_from':
              DateFormat('yyyy-MM-dd').format(selectedDates['dateFrom']!),
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
        appBar: CustomAppBar(
          title: _navigationItems[_selectedIndex].title,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          actions: <Widget>[
            if (userInfo.permission == 2)
              IconButton(
                icon: const Icon(Icons.calendar_today),
                tooltip: 'My Schedule',
                onPressed: () => _navigateToIndex(_navigationItems
                    .indexWhere((item) => item.title == 'My Schedule')),
              ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        drawer: AppDrawer(),
        // bottomNavigationBar: _buildBottomNavigationBar(),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: _currentScreen,
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: _buildBottomNavigationBar()),
          ],
        ),
      ),
    );
  }

  Widget AppDrawer() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: colorScheme.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.05),
                    colorScheme.secondary.withOpacity(0.07),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    width: 160,
                    child: Image.asset(
                      "assets/images/Logo_Dark.png",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      userInfo.permission == 2
                          ? "Dr. ${userInfo.username}"
                          : "Clinic",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  ..._navigationItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = _selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    colorScheme.primary.withOpacity(0.8),
                                    colorScheme.primary.withOpacity(0.6),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          leading: Icon(
                            item.icon,
                            color: isSelected ? Colors.white : Colors.black54,
                            size: 22,
                          ),
                          title: Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onTap: () => _navigateToIndex(index),
                        ),
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      leading: Icon(
                        Icons.file_download_outlined,
                        color: colorScheme.secondary,
                        size: 22,
                      ),
                      title: Text(
                        "Export Sales",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.secondary,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: _exportSales,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      leading: const Icon(
                        Icons.logout_outlined,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                      title: Text(
                        "Logout",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onTap: _logout,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.onSurface.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 14,
                    color: colorScheme.primary.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "PhysioUp v1.0.0",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _bottomNavItems.length,
                (index) => GestureDetector(
                  onTap: () => _onBottomNavTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _bottomNavItems[index].icon,
                          color: _selectedIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.65),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: _selectedIndex == index
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: _selectedIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.65),
                            letterSpacing: 0.2,
                          ),
                          child: Text(_bottomNavItems[index].label),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(top: 3),
                          height: 2.5,
                          width: _selectedIndex == index ? 16 : 0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
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

class BottomNavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  BottomNavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
