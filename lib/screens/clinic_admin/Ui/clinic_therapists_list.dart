// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/screens/clinic_admin/Ui/register_therapist.dart';
import 'package:phsyio_up/screens/clinic_admin/cubit/clinic_cubit.dart';

class ClinicTherapistsListScreen extends StatefulWidget {
  const ClinicTherapistsListScreen({super.key});

  @override
  State<ClinicTherapistsListScreen> createState() =>
      _ClinicTherapistsListScreenState();
}

class _ClinicTherapistsListScreenState
    extends State<ClinicTherapistsListScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClinicCubit()..initList(),
      child: BlocBuilder<ClinicCubit, ClinicState>(
        builder: (context, state) {
          ClinicCubit cubit = ClinicCubit.get(context);
          return Scaffold(
             appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 0,
              title: Text(
                "Clinic Therapists",
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              toolbarHeight: 60,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: cubit.refreshTherapists,
                  tooltip: "Refresh List",
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(onPressed: (){
              Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => RegisterTherapistScreen()));
            }, child: Icon(Icons.add),),
            body: RefreshIndicator(
              onRefresh: cubit.refreshTherapists,
              child: FutureBuilder<List<Therapist>>(
                future: cubit.therapistsFuture,
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
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load therapists',
                            style: GoogleFonts.jost(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: cubit.refreshTherapists,
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              'Try Again',
                              style: GoogleFonts.jost(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final therapists = snapshot.data ?? [];

                  if (therapists.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No therapists found',
                            style: GoogleFonts.jost(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: therapists.length,
                    itemBuilder: (context, index) {
                      final therapist = therapists[index];
                      return TherapistCard(
                        therapist: therapist,
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
}

class TherapistCard extends StatelessWidget {
  final Therapist therapist;

  const TherapistCard({
    super.key,
    required this.therapist,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  therapist.name.isNotEmpty
                      ? therapist.name.trim().split(' ').last[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.jost(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      therapist.name,
                      style: GoogleFonts.jost(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          therapist.phone.isEmpty
                              ? "No phone"
                              : therapist.phone,
                          style: GoogleFonts.jost(
                            fontSize: 14,
                            color: therapist.phone.isEmpty
                                ? Colors.grey.shade500
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
