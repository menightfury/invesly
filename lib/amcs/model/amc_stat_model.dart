import 'package:equatable/equatable.dart';

import 'amc_model.dart';

class AmcStat extends Equatable {
  const AmcStat({
    required this.accountId,
    required this.amc,
    this.numTransactions = 0,
    this.totalAmount = 0.0,
    this.totalQuantity = 0.0,
  });

  final String accountId;
  final InveslyAmc amc;
  final int numTransactions;
  final double totalAmount;
  final double totalQuantity;

  double get currentValue => (amc.ltp?.price ?? 0.0) * totalQuantity;

  AmcStat copyWith({
    String? accountId,
    InveslyAmc? amc,
    int? numTransactions,
    double? totalAmount,
    double? totalQuantity,
  }) {
    return AmcStat(
      accountId: accountId ?? this.accountId,
      amc: amc ?? this.amc,
      numTransactions: numTransactions ?? this.numTransactions,
      totalAmount: totalAmount ?? this.totalAmount,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }

  @override
  List<Object?> get props => [accountId, amc, numTransactions, totalAmount, totalQuantity];
}
