// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

class AmcOverviewState extends Equatable {
  const AmcOverviewState({required this.stat, this.ltpStatus = LatestPriceStatus.initial, this.ltp, this.errorMsg});

  final AmcStat stat;
  final LatestPriceStatus ltpStatus;
  final LatestPrice? ltp;
  final String? errorMsg;

  double get averageBuyPrice => stat.totalInvested / stat.totalQuantity;

  double? get totalCurrentValue {
    if (ltp == null) return null;
    return ltp!.price * stat.totalQuantity;
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
    AmcStat? stat,
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
