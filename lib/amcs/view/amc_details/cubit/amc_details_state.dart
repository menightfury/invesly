// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'amc_details_cubit.dart';

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
    this.amcStatus = AmcOverviewStatus.initial,
    this.amc,
    this.ltpStatus = AmcOverviewStatus.initial,
    this.ltp,
    this.transactionStatus = AmcOverviewStatus.initial,
    this.transactions = const [],
    this.errors = const {},
    // this.errorMsg,
  });

  final int accountId;
  final String amcId;
  final AmcOverviewStatus amcStatus;
  final InveslyAmc? amc;
  final AmcOverviewStatus ltpStatus;
  final LatestPrice? ltp;
  final AmcOverviewStatus transactionStatus;
  final List<InveslyTransaction> transactions;
  final Set<AmcOverviewErrorType> errors;
  // final String? errorMsg;

  @override
  List<Object?> get props => [
    accountId,
    amcId,
    amcStatus,
    amc,
    ltpStatus,
    ltp,
    transactionStatus,
    transactions,
    errors,
  ];

  int get numTransactions => transactions.length;
  double get totalQnty => transactions.fold<double>(0.0, (v, el) => v + (el.quantity ?? 0));
  double get totalInvested => transactions.fold<double>(0.0, (v, el) => v + (el.totalAmount > 0 ? el.totalAmount : 0));
  double get totalRedeemed => transactions.fold<double>(0.0, (v, el) => v + (el.totalAmount > 0 ? 0 : el.totalAmount));
  double get averageBuyPrice {
    if (totalQnty == 0) return 0;
    return totalInvested / totalQnty;
  }

  double? get currentValue {
    if (ltp == null) return null;
    if (totalQnty == 0) return 0;
    return ltp!.price * totalQnty;
  }

  double? get amountReturn => currentValue != null ? currentValue! - totalInvested : null;
  double? get perReturn => amountReturn != null && totalInvested > 0 ? (amountReturn! / totalInvested) * 100 : null;

  AmcOverviewState copyWith({
    AmcOverviewStatus? amcStatus,
    InveslyAmc? amc,
    AmcOverviewStatus? ltpStatus,
    LatestPrice? ltp,
    AmcOverviewStatus? transactionStatus,
    List<InveslyTransaction>? transactions,
    // String? errorMsg,
    Set<AmcOverviewErrorType>? errors,
  }) {
    return AmcOverviewState(
      accountId: accountId,
      amcId: amcId,
      amcStatus: amcStatus ?? this.amcStatus,
      amc: amc ?? this.amc,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      transactions: transactions ?? this.transactions,
      ltpStatus: ltpStatus ?? this.ltpStatus,
      ltp: ltp ?? this.ltp,
      // errorMsg: errorMsg ?? this.errorMsg,
      errors: errors ?? this.errors,
    );
  }
}

extension AmcOverviewStateX on AmcOverviewState {
  bool get isTrnLoading => [AmcOverviewStatus.initial, AmcOverviewStatus.loading].contains(transactionStatus);
  bool get isTrnLoaded => transactionStatus == AmcOverviewStatus.loaded;
  bool get isTrnError => transactionStatus == AmcOverviewStatus.error;

  bool get isAmcLoading => [AmcOverviewStatus.initial, AmcOverviewStatus.loading].contains(amcStatus);
  bool get isAmcLoaded => amcStatus == AmcOverviewStatus.loaded;
  bool get isAmcError => amcStatus == AmcOverviewStatus.error;

  bool get isLtpLoading => [AmcOverviewStatus.initial, AmcOverviewStatus.loading].contains(ltpStatus);
  bool get isLtpLoaded => ltpStatus == AmcOverviewStatus.loaded;
  bool get isLtpError => ltpStatus == AmcOverviewStatus.error;
}
