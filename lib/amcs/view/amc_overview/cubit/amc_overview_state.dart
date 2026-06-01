// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

class AmcOverviewState extends Equatable {
  const AmcOverviewState({
    required this.amcId,
    this.ltpStatus = LatestPriceStatus.initial,
    required this.stat,
    this.ltp,
    this.errorMsg,
  });

  final String amcId;
  final LatestPriceStatus ltpStatus;
  final AmcStat stat;
  final LatestPrice? ltp;
  final String? errorMsg;

  @override
  List<Object?> get props => [amcId, ltpStatus, stat, ltp, errorMsg];

  AmcOverviewState copyWith({
    String? amcId,
    LatestPriceStatus? ltpStatus,
    AmcStat? stat,
    LatestPrice? ltp,
    String? errorMsg,
  }) {
    return AmcOverviewState(
      amcId: amcId ?? this.amcId,
      ltpStatus: ltpStatus ?? this.ltpStatus,
      stat: stat ?? this.stat,
      ltp: ltp ?? this.ltp,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isLtpLoading => ltpStatus == LatestPriceStatus.loading;
  bool get isLtpLoaded => ltpStatus == LatestPriceStatus.loaded;
  bool get isLtpError => ltpStatus == LatestPriceStatus.error;
}
