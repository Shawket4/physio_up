// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/screens/referral/Ui/create_referral_screen.dart';
import 'package:phsyio_up/screens/referral/cubit/referral_cubit.dart';
import 'package:phsyio_up/screens/referral/Ui/edit_referral_screen.dart';
import 'package:phsyio_up/screens/referral/Ui/referral_packages_screen.dart';

class ReferralListScreen extends StatefulWidget {
  const ReferralListScreen({super.key});

  @override
  State<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends State<ReferralListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReferralCubit()..initGet(),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          ReferralCubit cubit = ReferralCubit.get(context);
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreateReferralScreen()))
                    .then((_) => cubit.refreshData());
              },
              icon: Icon(Icons.add),
              label: Text('Add Referral'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: RefreshIndicator(
              onRefresh: cubit.refreshData,
              child: FutureBuilder<List<Referral>>(
                future: cubit.referralsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !cubit.isRefreshing) {
                    return Center(
                      child: Lottie.asset(
                        "assets/lottie/Loading.json",
                        height: 200,
                        width: 200,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 60, color: Colors.red),
                          SizedBox(height: 16),
                          Text('Error loading referrals',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500)),
                          TextButton(
                            onPressed: cubit.refreshData,
                            child: Text('Try Again'),
                          )
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No Referrals Found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (userInfo.permission >= 2)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const CreateReferralScreen())
                          ).then((_) => cubit.refreshData());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Referral'),
                      ),
                  ],
                ),
              );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final referral = snapshot.data![index];
                      return ReferralCard(
                        referral: referral,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ReferralPackageScreen(
                                      referral: referral)));
                        },
                        onEdit: userInfo.permission >= 2
                            ? () async {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => EditReferralScreen(
                                            referral: referral)));
                                cubit.refreshData();
                              }
                            : null,
                        onDelete: userInfo.permission >= 2
                            ? () => showDeleteDialog(referral, cubit)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void showDeleteDialog(Referral referral, ReferralCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Referral'),
        content: Text(
            'Are you sure you want to delete ${referral.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await postData(
                  "$ServerIP/api/protected/DeleteReferral",
                  {"referral_id": referral.id},
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Referral deleted successfully"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );

                cubit.refreshData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete referral"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
                print("Error deleting referral: $e");
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class ReferralCard extends StatelessWidget {
  final Referral referral;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReferralCard({
    Key? key,
    required this.referral,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      referral.name.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: Theme.of(context).colorScheme.primary,
                            tooltip: 'Edit patient',
                            onPressed: onEdit,
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red.shade400,
                            tooltip: 'Delete patient',
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  "${referral.cashbackPercentage}% Cashback",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap to view packages',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
