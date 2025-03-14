part of 'patient_records_cubit.dart';

@immutable
sealed class PatientRecordsState {}

final class PatientRecordsInitial extends PatientRecordsState {}

final class UploadFilesSuccess extends PatientRecordsState {
  final List<PatientFile> files;
  UploadFilesSuccess(this.files);
}