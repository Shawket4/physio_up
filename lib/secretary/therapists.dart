import 'package:flutter/material.dart';
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

  Future<List<Therapist>> _fetchData() async {
      List<Therapist> therapists = [];
    try {
      dynamic response = await getData("$ServerIP/api/GetTherapists");
      // print(response);
      therapists = parseTherapists(response);
    } catch (e) {
      print("Error fetching data: $e");
    }
    return therapists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Therapists')),
      drawer: AppDrawer(),
      body: Center(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
            return  snapshot.data!.isEmpty ? Text("No Thearpists Found.") :
             ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final therapist = snapshot.data![index];
                return TherapistCard(therapist: therapist);
              },
            );
          }
          },
        ),
      ),
    );
  }
}

class TherapistCard extends StatelessWidget {
  final Therapist therapist;

  const TherapistCard({super.key, required this.therapist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TherapistDetailsScreen(therapist: therapist),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(therapist.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text("Phone: ${therapist.phone.isEmpty ? "N/A" : therapist.phone}"),
            ],
          ),
        ),
      ),
    );
  }
}
