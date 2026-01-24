// ignore_for_file: avoid_print

import 'package:xirr_flutter/xirr_flutter.dart' as xirr;

void main() {
  // Checking XIRR calculation
  List<xirr.Transaction> transactions = [];

  transactions.add(xirr.Transaction.withStringDate(-500, "2025-01-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-02-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-03-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-04-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-05-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-06-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-07-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-08-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-09-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-10-01"));
  transactions.add(xirr.Transaction.withStringDate(-500, "2025-11-01"));
  transactions.add(xirr.Transaction.withStringDate(5800, "2025-12-01"));

  final result = xirr.XirrFlutter.withTransactionsAndGuess(transactions, 0.1).calculate();
  print(result);
}
