part of 'accept_appointment_cubit.dart';

@immutable
sealed class AcceptAppointmentState {}

final class AcceptAppointmentInitial extends AcceptAppointmentState {}

final class FetchReferralsLoading extends AcceptAppointmentState {}

final class FetchReferralsSuccess extends AcceptAppointmentState {
  final List<Referral> referrals;
  FetchReferralsSuccess(this.referrals);
}

final class SetSelectedSuperTreatmentPlanId extends AcceptAppointmentState {
  final int selectedSuperTreatmentPlanId;
  SetSelectedSuperTreatmentPlanId(this.selectedSuperTreatmentPlanId);
}

final class SetSelectedReferral extends AcceptAppointmentState {
  final Referral selectedReferral;
  SetSelectedReferral(this.selectedReferral);
}