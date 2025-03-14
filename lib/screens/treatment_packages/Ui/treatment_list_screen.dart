import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/treatment_packages/Ui/create_treatment_screen.dart';
import 'package:phsyio_up/screens/treatment_packages/Ui/edit_treatment_screen.dart';

class TreatmentListScreen extends StatefulWidget {
  const TreatmentListScreen({super.key});

  @override
  State<TreatmentListScreen> createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State<TreatmentListScreen> {
  late Future<List<SuperTreatmentPlan>> _treatmentsFuture;
  
  @override
  void initState() {
    super.initState();
    _treatmentsFuture = _fetchData();
  }
  
  Future<List<SuperTreatmentPlan>> _fetchData() async {
    List<SuperTreatmentPlan> superTreatmentPlans = [];
    try {
      dynamic response = await getData("$ServerIP/api/FetchSuperTreatments");
      superTreatmentPlans = (response as List<dynamic>?)?.map((e) => SuperTreatmentPlan.fromJson(e)).toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
      // Rethrow to handle in the UI
      rethrow;
    }
    return superTreatmentPlans;
  }

  Future<void> _refreshData() async {
    setState(() {
      _treatmentsFuture = _fetchData();
    });
  }

  Future<void> _deleteTreatment(SuperTreatmentPlan treatmentPackage) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${treatmentPackage.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await postData(
        "$ServerIP/api/protected/DeleteSuperTreatment",
        {"package_id": treatmentPackage.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Package deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting package: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: userInfo.permission >= 2 
        ? FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const CreateTreatmentScreen())
              ).then((_) => _refreshData());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Package'),
            tooltip: 'Create new treatment package',
          ) 
        : null,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<SuperTreatmentPlan>>(
          future: _treatmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                    child: Lottie.asset(
                      "assets/lottie/Loading.json",
                      height: 200,
                      width: 200,
                    ),
                  );
            }
            
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading treatments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }
            
            final treatments = snapshot.data ?? [];
            
            if (treatments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No Treatment Packages Found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (userInfo.permission >= 2)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const CreateTreatmentScreen())
                          ).then((_) => _refreshData());
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Your First Package'),
                      ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: treatments.length,
              itemBuilder: (context, index) {
                final package = treatments[index];
                return _buildTreatmentCard(package);
              },
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildTreatmentCard(SuperTreatmentPlan package) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    package.description.toString(),
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (userInfo.permission >= 2)
                  Row(
                    children: [
                      IconButton(
                         icon: const Icon(Icons.edit_outlined),
                         color: Theme.of(context).colorScheme.primary,
                         tooltip: 'Edit patient',
                         onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (_) => EditTreatmentScreen(treatmentPackage: package)
                            )
                          ).then((_) => _refreshData());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                tooltip: 'Delete patient',
                        onPressed: () => _deleteTreatment(package),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_available, size: 20, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      "Sessions: ${package.sessionsCount}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      "Price: ${package.price}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}