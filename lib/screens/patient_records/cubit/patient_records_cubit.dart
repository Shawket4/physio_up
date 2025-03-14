import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phsyio_up/dio_helper.dart';
import 'package:phsyio_up/main.dart';
import '../../../models/patient_file.dart';
part 'patient_records_state.dart';

class PatientRecordsCubit extends Cubit<PatientRecordsState> {
  PatientRecordsCubit() : super(PatientRecordsInitial());
  static PatientRecordsCubit get(context) => BlocProvider.of(context);

  List<PatientFile> fileUrls = [];

Future<String> fetchFiles(int id) async {
  fileUrls.clear();
  try {
    dynamic response = await postData(
      "$ServerIP/api/protected/FetchPatientFilesURLs",
      {"ID": id},
    );
    // Parse the response into a list of PatientFile objects
    fileUrls = (response as List)
        .map((item) => PatientFile.fromJson(item))
        .toList();

    return "";
  } catch (e) {
    return "Failed to fetch files: $e";
  }
}

Future<void> downloadAndOpenFile(String fileName,int id,BuildContext context) async {
  try {
    // Get the directory for saving the file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    // Initialize Dio

    // Download the file using Dio
    await downloadData( '$ServerIP/api/protected/PatientRecords/${id}/$fileName',filePath);

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

Future<void> uploadFile(int id,BuildContext context) async {
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
        "id": id,
      });

      // Upload the files to the API
      await postData("$ServerIP/api/protected/UploadPatientRecord", formData);

      // Refresh the file list
      await fetchFiles(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Files uploaded successfully')),
      );

      // Update the UI
      emit(UploadFilesSuccess(fileUrls));
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
Future<void> deleteFile(String fileName, int id,BuildContext context) async {
  try {
    // Call the API to delete the file
    await postData(
      "$ServerIP/api/protected/DeletePatientRecord",
      {
        "id": id,
        "file_name": fileName,
      },
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File deleted successfully')),
    );

    // Refresh the file list
    await fetchFiles(id);
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete file: $e')),
    );
  }
}
}
