import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/treatment_packages/create_treatment_screen.dart';
import 'package:phsyio_up/screens/treatment_packages/edit_treatment_screen.dart';

import 'package:phsyio_up/secretary/router.dart';


class TreatmentListScreen extends StatefulWidget {

  const TreatmentListScreen({super.key});

  @override
  State<TreatmentListScreen> createState() => _TreatmentListScreenState();
}

class _TreatmentListScreenState extends State<TreatmentListScreen> {

  Future<List<SuperTreatmentPlan>> _fetchData() async {
      List<SuperTreatmentPlan> superTreatmentPlans = [];
    try {
      dynamic response = await getData("$ServerIP/api/FetchSuperTreatments");
      // print(response);
      superTreatmentPlans = (response as List<dynamic>?)?.map((e) => SuperTreatmentPlan.fromJson(e)).toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return superTreatmentPlans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:  userInfo.permission >= 2 ? FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateTreatmentScreen()));
      },
      child: Icon(Icons.add),
      ) : null,
      appBar: AppBar(title: Text('Tretment Packages')),
      drawer: AppDrawer(),
      body: Center(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
            return  snapshot.data!.isEmpty ? Text("No Packages Found.") :
             ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final treatmentPackage = snapshot.data![index];
                return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(treatmentPackage.description.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                 Text("Sessions Count: ${treatmentPackage.sessionsCount}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    SizedBox(height: 5),
                 Text("Price: ${treatmentPackage.price}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              ],
            ),
             userInfo.permission >= 2 ?
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditTreatmentScreen(treatmentPackage: treatmentPackage)));
                }, icon: Icon(Icons.edit,),),
                const SizedBox(width: 3,),
                 IconButton(onPressed: () async {
              try {
      await postData(
        "$ServerIP/api/protected/DeleteSuperTreatment",
        {"package_id": treatmentPackage.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Package Deleted!")),
                        );
                        setState(() {
                          
                        });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("An Error Occured!")),
                        );
      print("Error deleting package: $e");
    }
              
            }, icon: Icon(Icons.delete, color: Colors.red,),)
              ],
            ): Container()
           
          ],
        ),
      ),
    );
              },
            );
          }
          },
        ),
      ),
    );
  }
}

