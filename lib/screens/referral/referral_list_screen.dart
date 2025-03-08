import 'package:flutter/material.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/screens/referral/create_referral_screen.dart';
import 'package:phsyio_up/screens/referral/edit_referral_screen.dart';
import 'package:phsyio_up/screens/referral/referral_packages_screen.dart';

import 'package:phsyio_up/secretary/router.dart';


class ReferralListScreen extends StatefulWidget {

  const ReferralListScreen({super.key});

  @override
  State<ReferralListScreen> createState() => _ReferralListScreenState();
}

class _ReferralListScreenState extends State<ReferralListScreen> {

  Future<List<Referral>> _fetchData() async {
      List<Referral> referrals = [];
    try {
      dynamic response = await getData("$ServerIP/api/protected/FetchReferrals");
      // print(response);
      referrals = (response as List<dynamic>?)?.map((e) => Referral.fromJson(e)).toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return referrals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CreateReferralScreen()));
      },
      child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text('Referrals')),
      drawer: AppDrawer(),
      body: Center(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
            return  snapshot.data!.isEmpty ? Text("No Referrals Found.") :
             ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final referral = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ReferralPackageScreen(referral: referral)));
                  },
                  child: Card(
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
                  Text(referral.name.toString(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                   Text("Cashback Percentage: ${referral.cashbackPercentage}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                                ],
                              ),
                              userInfo.permission >= 2 ?
                              Row(
                                children: [
                  IconButton(
                    onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EditReferralScreen(referral: referral)));
                  }, icon: Icon(Icons.edit,),),
                  const SizedBox(width: 3,),
                   IconButton(onPressed: () async {
                                try {
                        await postData(
                          "$ServerIP/api/protected/DeleteReferral",
                          {"referral_id": referral.id},
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Referral Deleted!")),
                          );
                          setState(() {
                            
                          });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("An Error Occured!")),
                          );
                        print("Error deleting referral: $e");
                      }
                                
                              }, icon: Icon(Icons.delete, color: Colors.red,),)
                                ],
                              ) : Container()
                             
                            ],
                          ),
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

