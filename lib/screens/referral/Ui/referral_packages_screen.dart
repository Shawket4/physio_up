import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/components/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import 'package:phsyio_up/models/referral.dart';
import 'package:phsyio_up/screens/referral/cubit/referral_cubit.dart';

class ReferralPackageScreen extends StatefulWidget {
  final Referral referral;
  const ReferralPackageScreen({super.key, required this.referral});

  @override
  State<ReferralPackageScreen> createState() => _ReferralPackageScreenState();
}

class _ReferralPackageScreenState extends State<ReferralPackageScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReferralCubit(),
      child: BlocBuilder<ReferralCubit, ReferralState>(
        builder: (context, state) {
          ReferralCubit cubit = ReferralCubit.get(context);
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
                    await downloadDataPost(
                        '$ServerIP/api/protected/ExportReferredPackagesExcel',
                        filePath,
                        {"referral_id": widget.referral.id});

                    // Open the file
                    final result = await OpenFile.open(filePath);

                    if (result.type != ResultType.done) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to open file: ${result.message}')),
                      );
                    }
                  } on DioException catch (e) {
                    // Handle Dio-specific errors
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to download file: ${e.message}')),
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
                future: cubit.fetchReferralPackagesData(widget.referral),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(
                        "assets/lottie/Loading.json",
                        height: 200,
                        width: 200,
                      ),
                    );
                  } else {
                    return snapshot.data!.isEmpty
                        ? Text("No Referred Packages Found.")
                        : ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final treatmentPackage = snapshot.data![index];
                              return Card(
                                margin: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              treatmentPackage
                                                  .superTreatmentPlan!
                                                  .description!,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 5),
                                          Text(
                                              "Sessions Count: ${treatmentPackage.superTreatmentPlan!.sessionsCount}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
                                          SizedBox(height: 5),
                                          Text(
                                              "Price: ${treatmentPackage.superTreatmentPlan!.price}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
                                          Text(
                                              "Cashback: ${(widget.referral.cashbackPercentage! / 100) * treatmentPackage.totalPrice!}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
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
        },
      ),
    );
  }
}
