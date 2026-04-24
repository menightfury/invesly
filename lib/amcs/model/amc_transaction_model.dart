import 'package:equatable/equatable.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:xirr_flutter/xirr_flutter.dart' as xf;

import 'amc_model.dart';

class AmcTransaction extends Equatable {
  const AmcTransaction({required this.accountId, this.amc, this.transactions = const []});

  final String accountId;
  final InveslyAmc? amc;
  final List<InveslyTransaction> transactions;

  int get numTransactions => transactions.length;
  double get totalAmount => transactions.fold<double>(0.0, (v, el) => v + el.totalAmount);
  double get totalQuantity => transactions.fold<double>(0.0, (v, el) => v + el.quantity);
  double get currentValue => (amc?.ltp?.price ?? 0.0) * totalQuantity;
  double? get xirr {
    if (amc == null || amc?.ltp == null) return null;

    final transactionsForXirr = transactions.map((trn) => xf.Transaction(trn.totalAmount, trn.investedOn)).toList();
    if (transactionsForXirr.isNotEmpty) {
      transactionsForXirr.add(xf.Transaction(-currentValue, amc!.ltp!.date ?? amc!.ltp!.fetchDate));
    }
    final xirr = transactionsForXirr.isNotEmpty
        ? xf.XirrFlutter.withTransactionsAndGuess(transactionsForXirr, 0.1).calculate()
        : 0.0;
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
