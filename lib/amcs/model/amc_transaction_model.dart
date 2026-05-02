import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'amc_model.dart';

class AmcTransaction extends Equatable {
  const AmcTransaction({required this.accountId, this.amc, this.transactions = const []});

  final String accountId;
  final InveslyAmc? amc;
  final List<InveslyTransaction> transactions;

  int get numTransactions => transactions.length;
  double get totalInvested => transactions.fold<double>(0.0, (v, el) => v + el.totalAmount);
  double get totalQuantity => transactions.fold<double>(0.0, (v, el) => v + el.quantity);
  double? get currentValue {
    if (amc?.ltp == null) return null;
    return amc!.ltp!.price * totalQuantity;
  }

  double? get returns {
    if (currentValue == null) return null;
    return currentValue! - totalInvested;
  }

  double? get returnsPercent {
    if (returns == null || totalInvested == 0) return null;
    return (returns! / totalInvested) * 100;
  }

  double? get xirr {
    if (currentValue == null) return null;

    final transactionsForXirr = transactions.map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn)).toList();
    if (transactionsForXirr.isNotEmpty) {
      transactionsForXirr.add(xf.Transaction(-currentValue!, amc!.ltp!.date ?? amc!.ltp!.fetchDate));
    }
    double? xirr = 0.0;
    if (transactionsForXirr.isNotEmpty) {
      try {
        xirr = xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate();
      } catch (e) {
        debugPrint('Error calculating XIRR: $e');
      }
    }
    return xirr;
  }

  AmcTransaction copyWith({String? accountId, InveslyAmc? amc, List<InveslyTransaction>? transactions}) {
    return AmcTransaction(
      accountId: accountId ?? this.accountId,
      amc: amc ?? this.amc,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [accountId, amc, transactions];
}
