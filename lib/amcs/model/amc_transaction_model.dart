import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:invesly/common/extensions/num_extension.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'amc_model.dart';

class AmcTransaction extends Equatable {
  const AmcTransaction({required this.amc, this.transactions = const []});

  final InveslyAmc amc;
  final List<InveslyTransaction> transactions;

  int get numTransactions => transactions.length;
  double get totalInvested => transactions.fold<double>(0.0, (v, el) => v + el.totalAmount);
  double get totalUnits => transactions.fold<double>(0.0, (v, el) => v + (el.quantity ?? 0));
  double get averageBuyPrice => totalInvested / totalUnits;
  double? get totalCurrentValue {
    if (amc.ltp == null) return null;
    return amc.ltp!.price * totalUnits;
  }

  double? get amountReturn {
    if (totalCurrentValue == null) return null;
    return totalCurrentValue! - totalInvested;
  }

  double? get percentageReturn {
    if (amountReturn == null || totalInvested == 0) return null;
    return (amountReturn! / totalInvested) * 100;
  }

  double? get xirr {
    if (totalCurrentValue == null) return null;

    final transactionsForXirr = transactions.map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn)).toList();
    if (transactionsForXirr.isNotEmpty) {
      transactionsForXirr.add(xf.Transaction(-totalCurrentValue!, amc.ltp!.date ?? amc.ltp!.fetchDate));
    }
    double? xirr = 0.0;
    if (transactionsForXirr.isNotEmpty) {
      try {
        xirr = xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate()?.toPrecisionDouble(4);
      } catch (e) {
        debugPrint('Error calculating XIRR: $e');
      }
    }
    return xirr;
  }

  AmcTransaction copyWith({InveslyAmc? amc, List<InveslyTransaction>? transactions}) {
    return AmcTransaction(amc: amc ?? this.amc, transactions: transactions ?? this.transactions);
  }

  @override
  List<Object?> get props => [amc, transactions];
}
