import 'dart:async';

import 'package:csv/csv.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class TransactionRepository {
  TransactionRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  AccountTable get _accountTable => _api.accountTable;
  AmcTable get _amcTable => _api.amcTable;
  TransactionTable get _trnTable => _api.trnTable;

  Stream<TableChangeEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.table == _trnTable);
  }

  /// Get transactions
  Future<List<InveslyTransaction>> getTransactions({
    String? accountId,
    String? amcId,
    DateTimeRange? dateRange,
    int? limit,
  }) async {
    final filter = <TableFilter>[];
    if (accountId != null) {
      filter.add(SingleValueTableFilter<String>(_trnTable.accountIdColumn, accountId));
    }

    if (amcId != null) {
      filter.add(SingleValueTableFilter<String>(_trnTable.amcIdColumn, amcId));
    }

    if (dateRange != null) {
      filter.add(
        RangeValueTableFilter(
          _trnTable.dateColumn,
          dateRange.start.millisecondsSinceEpoch,
          dateRange.end.millisecondsSinceEpoch,
        ),
      );
    }

    late final List<InveslyTransaction> transactions;
    try {
      final result = await _api.select(_trnTable).join([_accountTable, _amcTable]).where(filter).toList(limit: limit);
      // orderBy: '${_trnTable.dateColumn.title} DESC',
      // limit: showItems,

      if (result.isEmpty) return List<InveslyTransaction>.empty();

      transactions = result.map<InveslyTransaction>((map) {
        return InveslyTransaction.fromDb(
          _trnTable.fromMap(map),
          _accountTable.fromMap(map[_accountTable.type.toString().toCamelCase()] as Map<String, dynamic>),
          _amcTable.fromMap(map[_amcTable.type.toString().toCamelCase()] as Map<String, dynamic>),
        );
      }).toList();
    } on Exception catch (err) {
      $logger.e(err);
      transactions = List<InveslyTransaction>.empty();
    }

    return transactions;
  }

  /// Get transaction statistics
  Future<List<TransactionStat>> getTransactionStats(String accountId) async {
    try {
      final result = await _api
          .select(_trnTable, [
            ..._amcTable.columns,
            _trnTable.idColumn.count('num_transactions'),
            _trnTable.amountColumn.sum('total_amount'),
          ])
          .join([_amcTable])
          .where([SingleValueTableFilter<String>(_trnTable.accountIdColumn, accountId)])
          .groupBy([_amcTable.nameColumn])
          .toList();
      final stats = result.map<TransactionStat>((map) {
        return TransactionStat(
          accountId: accountId,
          amc: InveslyAmc.fromDb(_amcTable.fromMap(map)),
          numTransactions: map['num_transactions'] as int,
          totalAmount: (map['total_amount'] as num).toDouble(),
        );
      }).toList();
      return stats;
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
      // stats = List<TransactionStat>.empty();
    }
  }

  /// Add or update a transaction
  Future<void> saveTransaction(TransactionInDb transaction, [bool isNew = true]) async {
    if (isNew) {
      await _api.insert(_trnTable, transaction);
    } else {
      await _api.update(_trnTable, transaction);
    }
  }

  /// Insert multiple transaction at once
  Future<void> insertTransactions(List<TransactionInDb> transactions) async {
    final batch = _api.db.batch();
    // ignore: avoid_function_literals_in_foreach_calls
    transactions.forEach((trn) => batch.insert(_trnTable.tableName, _trnTable.fromModel(trn)));

    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<String> transactionsToCsv([String separator = ',']) async {
    final csvHeader = _trnTable.columns.map((col) => col.title.toCamelCase()).toList();
    final transactions = await getTransactions();

    final csvData = transactions.map((trn) => _trnTable.fromModel(trn).values.toList()).toList();

    return const ListToCsvConverter().convert([csvHeader, ...csvData], fieldDelimiter: separator);
  }
}
