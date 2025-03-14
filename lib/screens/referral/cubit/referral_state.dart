part of 'referral_cubit.dart';

@immutable
sealed class ReferralState {}

final class ReferralInitial extends ReferralState {}

final class RefreshDataLoading extends ReferralState {}

final class RefreshDataSuccess extends ReferralState {
  final List<Referral> referrals;
  RefreshDataSuccess(this.referrals);
}