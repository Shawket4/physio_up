import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/therapist.dart';
import 'package:phsyio_up/secretary/router.dart';
import 'package:phsyio_up/secretary/therapist_detail_screen.dart';

class TherapistListScreen extends StatefulWidget {
  const TherapistListScreen({super.key});

  @override
  State<TherapistListScreen> createState() => _TherapistListScreenState();
}

class _TherapistListScreenState extends State<TherapistListScreen> {
  late Future<List<Therapist>> _therapistsFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _therapistsFuture = _fetchData();
  }

  Future<void> _refreshTherapists() async {
    setState(() {
      _isRefreshing = true;
    });
    
    _therapistsFuture = _fetchData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<List<Therapist>> _fetchData() async {
    List<Therapist> therapists = [];
    try {
      dynamic response = await getData("$ServerIP/api/GetTherapists");
      therapists = parseTherapists(response);
    } catch (e) {
      print("Error fetching data: $e");
      // We'll handle this in the UI
    }
    return therapists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshTherapists,
        child: FutureBuilder<List<Therapist>>(
          future: _therapistsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
              return const Center(
                child: CircularProgressIndicator(),
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
                      onPressed: _refreshTherapists,
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TherapistDetailsScreen(therapist: therapist),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                          therapist.phone.isEmpty ? "No phone" : therapist.phone,
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