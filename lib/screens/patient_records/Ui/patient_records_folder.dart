import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/screens/patient_records/cubit/patient_records_cubit.dart';

class PatientFileExplorerScreen extends StatefulWidget {
  final int patientID;
  const PatientFileExplorerScreen({super.key, required this.patientID});

  @override
  _PatientFileExplorerScreenState createState() =>
      _PatientFileExplorerScreenState();
}

class _PatientFileExplorerScreenState extends State<PatientFileExplorerScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientRecordsCubit(),
      child: BlocBuilder<PatientRecordsCubit, PatientRecordsState>(
        builder: (context, state) {
          PatientRecordsCubit cubit = PatientRecordsCubit.get(context);
          return Scaffold(
            appBar: CustomAppBar(title: "Patient File Explorer", actions: []),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                 cubit.uploadFile(widget.patientID,context);
              },
              child: Icon(Icons.upload_file),
            ),
            body: Center(
              child: FutureBuilder(
                  future: cubit.fetchFiles(widget.patientID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      Center(
                        child: Lottie.asset(
                          "assets/lottie/Loading.json",
                          height: 200,
                          width: 200,
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          if (cubit.fileUrls.isEmpty)
                            Text('No files found for this patient.')
                          else
                            Expanded(
                              child: ListView.builder(
                                itemCount: cubit.fileUrls.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                       cubit.downloadAndOpenFile(
                                           cubit.fileUrls[index].name,widget.patientID,context);
                                    },
                                    child: Card(
                                      margin: EdgeInsets.all(5),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6)),
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
                                                Text( cubit.fileUrls[index].name,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(height: 5),
                                                Text( cubit.fileUrls[index].sizeInMB,
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                   cubit.deleteFile(
                                                       cubit.fileUrls[index].name,widget.patientID,context);
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
            ),
          );
        },
      ),
    );
  }
}
