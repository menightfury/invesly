import 'package:equatable/equatable.dart';

import '../../amcs/model/amc_model.dart';

class AmcStat extends Equatable {
  const AmcStat({
    required this.accountId,
    required this.amc,
    this.numTransactions = 0,
    this.totalQuantity = 0.0,
    this.totalInvested = 0.0,
    this.totalRedeemed = 0.0,
  });

  final String accountId;
  final InveslyAmc amc;
  final int numTransactions;
  final double totalQuantity;
  final double totalInvested;
  final double totalRedeemed;

  double? get currentValue {
    if (amc.ltp == null) return null;
    return amc.ltp!.price * totalQuantity;
  }

  double? get amountReturn {
    if (currentValue == null) return null;
    return currentValue! - totalInvested;
  }

  double? get percentageReturn {
    if (amountReturn == null || totalInvested == 0) return null;
    return (amountReturn! / totalInvested) * 100;
  }

  AmcStat copyWith({
    String? accountId,
    InveslyAmc? amc,
    int? numTransactions,
    double? totalQuantity,
    double? totalInvested,
    double? totalRedeemed,
  }) {
    return AmcStat(
      accountId: accountId ?? this.accountId,
      amc: amc ?? this.amc,
      numTransactions: numTransactions ?? this.numTransactions,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalInvested: totalInvested ?? this.totalInvested,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
    );
  }

  @override
  List<Object?> get props => [accountId, amc, numTransactions, totalQuantity, totalInvested, totalRedeemed];
}
