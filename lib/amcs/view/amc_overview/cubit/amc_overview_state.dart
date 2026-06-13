// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

class AmcOverviewState extends Equatable {
  const AmcOverviewState({required this.amcId, this.ltpStatus = LatestPriceStatus.initial, this.ltp, this.errorMsg});

  final String amcId;
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
  List<Object?> get props => [amcId, ltpStatus, ltp, errorMsg];

  AmcOverviewState copyWith({String? amcId, LatestPriceStatus? ltpStatus, LatestPrice? ltp, String? errorMsg}) {
    return AmcOverviewState(
      ltpStatus: ltpStatus ?? this.ltpStatus,
      amcId: amcId ?? this.amcId,
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
