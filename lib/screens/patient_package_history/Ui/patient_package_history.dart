// ignore_for_file: deprecated_member_use
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/screens/patient_package_appointment/Ui/patient_package_appointments.dart';
import 'package:phsyio_up/screens/patient_package_history/cubit/patient_package_history_cubit.dart';
import 'package:phsyio_up/screens/referral/Ui/set_referral_screen.dart';

class PatientPackageHistoryScreen extends StatefulWidget {
  final int PatientID;
  const PatientPackageHistoryScreen({super.key, required this.PatientID});

  @override
  State<PatientPackageHistoryScreen> createState() =>
      _PatientPackageHistoryScreenState();
}

class _PatientPackageHistoryScreenState
    extends State<PatientPackageHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientPackageHistoryCubit(),
      child: BlocBuilder<PatientPackageHistoryCubit, PatientPackageHistoryState>(
        builder: (context, state) {
          final cubit = PatientPackageHistoryCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Packages", actions: []),
            body: FutureBuilder(
              future: cubit.fetchPatientPackageHistory(widget.PatientID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No package history found'),
                  );
                } else {
                  // Split packages into active and history
                  final activePackages = snapshot.data!
                      .where((package) => package.remaining! > 0)
                      .toList();
                  final historyPackages = snapshot.data!
                      .where((package) => package.remaining! <= 0)
                      .toList();

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Packages Section
                          _buildSectionHeader(context, "Active Packages",
                              Icons.bookmark, Colors.blue),
                          if (activePackages.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: Text("No active packages")),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activePackages.length,
                              itemBuilder: (context, index) {
                                return _buildPackageCard(
                                    context, activePackages[index], true,cubit);
                              },
                            ),
                          const SizedBox(height: 24),

                          // History Section
                          _buildSectionHeader(context, "Package History",
                              Icons.history, Colors.grey),
                          if (historyPackages.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: Text("No package history")),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historyPackages.length,
                              itemBuilder: (context, index) {
                                return _buildPackageCard(
                                    context, historyPackages[index], false,cubit);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: color.withOpacity(0.5), thickness: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(
      BuildContext context, TreatmentPlan package, bool isActive,PatientPackageHistoryCubit cubit) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive
              ? Colors.blue.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      elevation: isActive ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientPackageAppointments(PackageID: package.id!),
          ),
        ).then((_) => setState(() {})),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${package.superTreatmentPlan?.description ?? 'No description'}",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusIndicators(package,cubit,context),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow("Date", package.date ?? "Not specified"),
                        _buildInfoRow("Price",
                            "\$${package.superTreatmentPlan?.price ?? 0}"),
                        _buildInfoRow("Discount", "${package.discount ?? 0}%"),
                        _buildInfoRow("Total",
                            "\$${package.totalPrice?.toStringAsFixed(2) ?? 0}"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSessionsIndicator(
                            context, package.remaining ?? 0),
                        const SizedBox(height: 8),
                        _buildActionButton(context, package),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsIndicator(BuildContext context, int remaining) {
    final Color color = remaining > 0 ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            remaining > 0 ? Icons.event_available : Icons.event_busy,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            "$remaining sessions remaining",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators(TreatmentPlan package,PatientPackageHistoryCubit cubit,BuildContext context) {
    return Row(
      children: [
        if (package.isPaid ?? false)
          Tooltip(
            message: "Paid",
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.monetization_on,
                  color: Colors.green, size: 20),
            ),
          ),
        const SizedBox(width: 8),
        _buildPackageMenu(package,cubit,context),
      ],
    );
  }

  Widget _buildPackageMenu(TreatmentPlan package,PatientPackageHistoryCubit cubit,BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (String value) async {
        if (value == "delete") {
          await _showDeleteConfirmation(package,cubit,context);
        } else if (value == "set_referral") {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SetReferralScreen(package: package)),
          ).then((_) => setState(() {}));
        } else if (value == "mark_as_paid") {
          await cubit.markPackageAsPaid(package.id,context);
        } else if (value == "mark_as_unpaid") {
          await cubit.markPackageAsUnpaid(package.id,context);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'set_referral',
            child: Row(
              children: [
                Icon(Icons.person_add, size: 18),
                SizedBox(width: 8),
                Text('Set Referral'),
              ],
            ),
          ),
          if (package.isPaid ?? false)
            const PopupMenuItem<String>(
              value: 'mark_as_unpaid',
              child: Row(
                children: [
                  Icon(Icons.money_off, size: 18),
                  SizedBox(width: 8),
                  Text('Mark As Unpaid'),
                ],
              ),
            )
          else
            const PopupMenuItem<String>(
              value: 'mark_as_paid',
              child: Row(
                children: [
                  Icon(Icons.attach_money, size: 18),
                  SizedBox(width: 8),
                  Text('Mark As Paid'),
                ],
              ),
            ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Package', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildActionButton(BuildContext context, TreatmentPlan package) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientPackageAppointments(PackageID: package.id!),
        ),
      ).then((_) => setState(() {})),
      icon: const Icon(Icons.calendar_month),
      label: const Text('View Appointments'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(TreatmentPlan package,PatientPackageHistoryCubit cubit,BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Package'),
          content: const Text(
              'Are you sure you want to delete this package? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await cubit.deletePackage(package.id,context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
