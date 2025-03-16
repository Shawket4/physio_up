part of 'patient_package_history_cubit.dart';

@immutable
sealed class PatientPackageHistoryState {}

final class PatientPackageHistoryInitial extends PatientPackageHistoryState {}

final class DeletePackageSuccess extends PatientPackageHistoryState {
  final String message;
  DeletePackageSuccess(this.message);
}

final class MarkPackageAsPaid extends PatientPackageHistoryState {}

final class MarkPackageAsUnpaid extends PatientPackageHistoryState {}