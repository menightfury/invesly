// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

enum AmcOverviewStatus { initial, loading, loaded, error }

class AmcOverviewState extends Equatable {
  const AmcOverviewState({
    this.status = AmcOverviewStatus.initial,
    required this.accountId,
    required this.amcId,
    this.ltpStatus = LatestPriceStatus.initial,
    this.stat,
    this.errorMsg,
  });

  final AmcOverviewStatus status;
  final String accountId;
  final String amcId;
  final LatestPriceStatus ltpStatus;
  final AmcStat? stat;
  final String? errorMsg;

  @override
  List<Object?> get props => [status, accountId, amcId, ltpStatus, stat, errorMsg];

  AmcOverviewState copyWith({
    AmcOverviewStatus? status,
    String? accountId,
    String? amcId,
    LatestPriceStatus? ltpStatus,
    AmcStat? stat,
    String? errorMsg,
  }) {
    return AmcOverviewState(
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      amcId: amcId ?? this.amcId,
      ltpStatus: ltpStatus ?? this.ltpStatus,
      stat: stat ?? this.stat,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isLtpLoading => ltpStatus == LatestPriceStatus.loading;
  bool get isLtpLoaded => ltpStatus == LatestPriceStatus.loaded;
  bool get isLtpError => ltpStatus == LatestPriceStatus.error;
}
