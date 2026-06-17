// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_overview_cubit.dart';

enum AmcOverviewStatus { initial, loading, loaded, error }

enum AmcOverviewErrorType {
  transaction,
  amc,
  ltp;

  String get errorMsg {
    return switch (this) {
      transaction => 'Error getting transactions',
      amc => 'Error getting amc details',
      ltp => 'Error getting latest price',
    };
  }
}

class AmcOverviewState extends Equatable {
  const AmcOverviewState({
    required this.accountId,
    required this.amcId,
    this.status = AmcOverviewStatus.initial,
    this.amc,
    this.ltpStatus = LatestPriceStatus.initial,
    this.ltp,
    this.transactions = const [],
    this.errors = const [],
    // this.errorMsg,
  });

  final int accountId;
  final String amcId;
  final AmcOverviewStatus status;
  final InveslyAmc? amc;
  final LatestPriceStatus ltpStatus;
  final LatestPrice? ltp;
  final List<InveslyTransaction> transactions;
  final List<AmcOverviewErrorType> errors;
  // final String? errorMsg;

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
  List<Object?> get props => [accountId, amcId, amc, ltpStatus, ltp, transactions, errors];

  int get numTransactions => transactions.length;
  double get totalQuantity => transactions.fold<double>(0.0, (v, el) => v + (el.quantity ?? 0));
  double get totalInvested => transactions.fold<double>(0.0, (v, el) => v + (el.totalAmount > 0 ? el.totalAmount : 0));
  double get totalRedeemed => transactions.fold<double>(0.0, (v, el) => v + (el.totalAmount > 0 ? 0 : el.totalAmount));
  double get averageBuyPrice {
    if (totalQuantity == 0) return 0;
    return totalInvested / totalQuantity;
  }

  AmcOverviewState copyWith({
    AmcOverviewStatus? status,
    InveslyAmc? amc,
    LatestPriceStatus? ltpStatus,
    LatestPrice? ltp,
    List<InveslyTransaction>? transactions,
    // String? errorMsg,
    List<AmcOverviewErrorType>? errors,
  }) {
    return AmcOverviewState(
      accountId: accountId,
      amcId: amcId,
      status: status ?? this.status,
      amc: amc ?? this.amc,
      ltpStatus: ltpStatus ?? this.ltpStatus,
      ltp: ltp ?? this.ltp,
      transactions: transactions ?? this.transactions,
      // errorMsg: errorMsg ?? this.errorMsg,
      errors: errors ?? this.errors,
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
