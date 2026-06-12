// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

class AmcOverviewState extends Equatable {
  const AmcOverviewState({required this.stat, this.ltpStatus = LatestPriceStatus.initial, this.ltp, this.errorMsg});

  final InveslyStat stat;
  final LatestPriceStatus ltpStatus;
  final LatestPrice? ltp;
  final String? errorMsg;

  double get averageBuyPrice {
    if (stat.totalQnty == 0) return 0;
    return stat.totalInvested / stat.totalQnty;
  }

  double? get totalCurrentValue {
    if (ltp == null) return null;

    if (stat.totalQnty == 0) return 0;

    return ltp!.price * stat.totalQnty;
  }

  double? get amountReturn {
    if (totalCurrentValue == null) return null;
    return totalCurrentValue! - stat.totalInvested;
  }

  double? get percentageReturn {
    if (amountReturn == null || stat.totalInvested == 0) return null;
    return (amountReturn! / stat.totalInvested) * 100;
  }

  @override
  List<Object?> get props => [stat, ltpStatus, ltp, errorMsg];

  AmcOverviewState copyWith({
    String? amcId,
    LatestPriceStatus? ltpStatus,
    InveslyStat? stat,
    LatestPrice? ltp,
    String? errorMsg,
  }) {
    return AmcOverviewState(
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
