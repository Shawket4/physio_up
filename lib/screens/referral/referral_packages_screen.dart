import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/models/treatment_plan.dart';
import 'package:phsyio_up/screens/treatment_packages/create_treatment_screen.dart';
import 'package:phsyio_up/screens/treatment_packages/edit_treatment_screen.dart';

import 'package:phsyio_up/secretary/router.dart';


class ReferralPackageScreen extends StatefulWidget {
  final Referral referral;
  const ReferralPackageScreen({super.key, required this.referral});

  @override
  State<ReferralPackageScreen> createState() => _ReferralPackageScreenState();
}

class _ReferralPackageScreenState extends State<ReferralPackageScreen> {

  Future<List<TreatmentPlan>> _fetchData() async {
      List<TreatmentPlan> treatmentPlans = [];
    try {
      dynamic response = await postData("$ServerIP/api/protected/FetchReferralPackages", {
        "referral_id": widget.referral.id,
      });
      print(response);
      treatmentPlans = (response as List<dynamic>?)?.map((e) => TreatmentPlan.fromJson(e)).toList() ?? [];
    } catch (e) {
      print("Error fetching data: $e");
    }
    return treatmentPlans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Referred Packages", actions: []),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.book),
        onPressed: () async {
        try {
         final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/Referral.xlsx";

    // Initialize Dio

    // Download the file using Dio
    await downloadDataPost('$ServerIP/api/protected/ExportReferredPackagesExcel',filePath, {"referral_id": widget.referral.id});

    // Open the file
    final result = await OpenFile.open(filePath);

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open file: ${result.message}')),
      );
    }
  } on DioException catch (e) {
    // Handle Dio-specific errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to download file: ${e.message}')),
    );
  } catch (e) {
    // Handle other errors
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
      }),
      body: Center(
        child: FutureBuilder(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
            return  snapshot.data!.isEmpty ? Text("No Referred Packages Found.") :
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
                Text(treatmentPackage.superTreatmentPlan!.description!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                 Text("Sessions Count: ${treatmentPackage.superTreatmentPlan!.sessionsCount}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                    SizedBox(height: 5),
                 Text("Price: ${treatmentPackage.superTreatmentPlan!.price}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                 Text("Cashback: ${(widget.referral.cashbackPercentage! / 100) * treatmentPackage.totalPrice!}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              ],
            ),
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

