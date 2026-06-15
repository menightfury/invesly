// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

enum AmcOverviewStatus { initial, loading, loaded, error }

class AmcOverviewState extends Equatable {
  const AmcOverviewState({
    required this.amcId,
    this.status = AmcOverviewStatus.initial,
    this.amc,
    this.ltpStatus = LatestPriceStatus.initial,
    this.ltp,
    this.errorMsg,
  });

  final String amcId;
  final AmcOverviewStatus status;
  final InveslyAmc? amc;
  final LatestPriceStatus ltpStatus;
  final LatestPrice? ltp;
  final String? errorMsg;

  // double get averageBuyPrice {
  //   if (amcId.totalQnty == 0) return 0;
  //   return amcId.totalInvested / amcId.totalQnty;
  // }

  // double? get totalCurrentValue {
  //   if (ltp == null) return null;

  //   if (amcId.totalQnty == 0) return 0;

  //   return ltp!.price * amcId.totalQnty;
  // }

  // double? get amountReturn {
  //   if (totalCurrentValue == null) return null;
  //   return totalCurrentValue! - amcId.totalInvested;
  // }

  // double? get percentageReturn {
  //   if (amountReturn == null || amcId.totalInvested == 0) return null;
  //   return (amountReturn! / amcId.totalInvested) * 100;
  // }

  @override
  List<Object?> get props => [amcId, amc, ltpStatus, ltp, errorMsg];

  AmcOverviewState copyWith({
    AmcOverviewStatus? status,
    InveslyAmc? amc,
    LatestPriceStatus? ltpStatus,
    LatestPrice? ltp,
    String? errorMsg,
  }) {
    return AmcOverviewState(
      amcId: amcId,
      status: status ?? this.status,
      amc: amc ?? this.amc,
      ltpStatus: ltpStatus ?? this.ltpStatus,
      ltp: ltp ?? this.ltp,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isInitial => status == AmcOverviewStatus.initial;
  bool get isLoading => status == AmcOverviewStatus.loading;
  bool get isLoaded => status == AmcOverviewStatus.loaded;
  bool get isError => status == AmcOverviewStatus.error;

  bool get isLtpLoading => ltpStatus == LatestPriceStatus.loading;
  bool get isLtpLoaded => ltpStatus == LatestPriceStatus.loaded;
  bool get isLtpError => ltpStatus == LatestPriceStatus.error;
}
