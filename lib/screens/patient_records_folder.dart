import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/components/app_bar.dart';
import 'package:phsyio_up/dio_helper.dart';

import 'package:phsyio_up/main.dart';

class PatientFileExplorerScreen extends StatefulWidget {
  final int patientID;
  const PatientFileExplorerScreen({super.key, required this.patientID});

  @override
  _PatientFileExplorerScreenState createState() =>
      _PatientFileExplorerScreenState();
}

class _PatientFileExplorerScreenState extends State<PatientFileExplorerScreen> {
  List<PatientFile> _fileUrls = [];

Future<String> _fetchFiles() async {
  _fileUrls.clear();
  try {
    dynamic response = await postData(
      "$ServerIP/api/protected/FetchPatientFilesURLs",
      {"ID": widget.patientID},
    );
    // Parse the response into a list of PatientFile objects
    _fileUrls = (response as List)
        .map((item) => PatientFile.fromJson(item))
        .toList();

    return "";
  } catch (e) {
    return "Failed to fetch files: $e";
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Patient File Explorer", actions: []),
      floatingActionButton: FloatingActionButton(onPressed: _uploadFile, child: Icon(Icons.upload_file),),
      body: Center(
        child: FutureBuilder(
          future: _fetchFiles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  if (_fileUrls.isEmpty)
                    Text('No files found for this patient.')
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _fileUrls.length,
                        itemBuilder: (context, index) {
                       return GestureDetector(
                        onTap: () {
                          _downloadAndOpenFile(_fileUrls[index].name);
                        },
                         child: Card(
                                 margin: EdgeInsets.all(5),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                 elevation: 3,
                                 child: Padding(
                                   padding: EdgeInsets.all(15),
                                   child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                     children: [
                                       Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(_fileUrls[index].name,
                                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                SizedBox(height: 5),
                                                Text(_fileUrls[index].sizeInMB,
                                               style: TextStyle(fontSize: 16)),
                                           SizedBox(height: 5),
                                         ],
                                       ),
                                       IconButton(onPressed: () {
                                        _deleteFile(_fileUrls[index].name);
                                        setState(() {
                                          
                                        });
                                       }, icon: Icon(Icons.delete, color: Colors.red,))
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
          }
        ),
      ),
    );
  }
  
  Future<void> _downloadAndOpenFile(String fileName) async {
  try {
    // Get the directory for saving the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    // Initialize Dio

    // Download the file using Dio
    await downloadData( '$ServerIP/api/protected/PatientRecords/${widget.patientID}/$fileName',filePath);

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
  
}

Future<void> _uploadFile() async {
  try {
    // Open file picker and allow multiple file selection
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true, // Allow multiple file selection
    );

    if (result != null) {
      // Create a list of MultipartFile objects for the selected files
      List<MultipartFile> multipartFiles = [];
      for (PlatformFile file in result.files) {
        multipartFiles.add(
          await MultipartFile.fromFile(file.path!, filename: file.name),
        );
      }

      // Create FormData for the file upload
      FormData formData = FormData.fromMap({
        "files": multipartFiles, // Use "files" as the key for multiple files
        "id": widget.patientID,
      });

      // Upload the files to the API
      await postData("$ServerIP/api/protected/UploadPatientRecord", formData);

      // Refresh the file list
      await _fetchFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files uploaded successfully')),
      );

      // Update the UI
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No files selected')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading files: $e')),
    );
  }
}
Future<void> _deleteFile(String fileName) async {
  try {
    // Call the API to delete the file
    await postData(
      "$ServerIP/api/protected/DeletePatientRecord",
      {
        "id": widget.patientID,
        "file_name": fileName,
      },
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File deleted successfully')),
    );

    // Refresh the file list
    await _fetchFiles();
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete file: $e')),
    );
  }
}
}

class PatientFile {
  final String name;
  final double size; // Size in bytes

  PatientFile({required this.name, required this.size});

  factory PatientFile.fromJson(Map<String, dynamic> json) {
    print(json);
    return PatientFile(
      name: json['name'],
      size: double.parse(json['size'].toString()),
    );
  }

  // Convert size to megabytes (MB)
  String get sizeInMB {
    return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}