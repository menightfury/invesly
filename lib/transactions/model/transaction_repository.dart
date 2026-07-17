import 'dart:async';

import 'package:csv/csv.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class TransactionRepository {
  // singleton api instance
  static TransactionRepository? _instance;
  static TransactionRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory TransactionRepository.initialize(InveslyApi api) {
    _instance ??= TransactionRepository._(api);
    return _instance!;
  }
  const TransactionRepository._(this._api);

  final InveslyApi _api;

  AccountTable get _accountTable => _api.accountTable;
  AmcTable get _amcTable => _api.amcTable;
  TransactionTable get _trnTable => _api.trnTable;

  Stream<TableEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.table == _trnTable);
  }

  /// Get transactions
  Future<List<InveslyTransaction>> getTransactions({
    int? accountId,
    AmcGenre? genre,
    String? amcId,
    DateTimeRange? dateRange,
    int? limit,
    bool descendingOrder = true,
  }) async {
    final filters = <TableFilter>[];
    if (accountId != null) {
      filters.add(SingleValueTableFilter<int>(_trnTable.accountIdColumn, accountId));
    }

    if (genre != null) {
      filters.add(SingleValueTableFilter<String>(_amcTable.genreColumn, genre.name));
    }

    if (amcId != null) {
      filters.add(SingleValueTableFilter<String>(_trnTable.amcIdColumn, amcId));
    }

    if (dateRange != null) {
      filters.add(
        RangeValueTableFilter(
          _trnTable.dateColumn,
          dateRange.start.millisecondsSinceEpoch,
          dateRange.end.millisecondsSinceEpoch,
        ),
      );
    }

    late final List<InveslyTransaction> transactions;
    try {
      final result = await _api.select(
        _trnTable,
        join: [_accountTable, _amcTable],
        filter: filters.isEmpty ? null : TableFilterGroup(filters),
        limit: limit,
        orderBy: {_trnTable.dateColumn: true},
      );

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

  /// Add or update a transaction
  Future<void> saveTransaction(TransactionInDb transaction, [bool isNew = true]) async {
    if (isNew) {
      await _api.insert(_trnTable, transaction);
    } else {
      await _api.update(_trnTable, transaction);

      // TableEventType.insert =>
      //   '''
      //     INSERT OR IGNORE INTO ${stat.tableName} ($accId, $amcId, $numTx, $qty, $invested, $redeemed)
      //     VALUES (NEW.$trnAccId, NEW.$trnAmcId, 1, NEW.$trnQty, IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0), IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0))
      //     ON CONFLICT($accId, $amcId) DO
      //     UPDATE SET
      //       $numTx = $numTx + 1,
      //       $qty = $qty + COALESCE(NEW.$trnQty, 0),
      //       $invested = $invested + IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0),
      //       $redeemed = $redeemed + IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0),
      //       $xirr = NULL; -- reset xirr to be recalculated later
      //   ''',

      // TableEventType.update =>
      //   '''
      //     UPDATE ${stat.tableName} SET
      //       $qty = $qty - COALESCE(OLD.$trnQty, 0) + COALESCE(NEW.$trnQty, 0),
      //       $invested = $invested - IIF(OLD.$trnAmt > 0, OLD.$trnAmt, 0) + IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0),
      //       $redeemed = $redeemed - IIF(OLD.$trnAmt < 0, OLD.$trnAmt, 0) + IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0),
      //       $xirr = NULL -- reset xirr to be recalculated later
      //     WHERE $accId = NEW.$trnAccId AND $amcId = NEW.$trnAmcId;
      //   ''',
      // await _api.update(_api.statTable, StatInDb.fromTransaction(transaction));
    }
  }

  /// Insert multiple transaction at once
  Future<void> insertTransactions(List<TransactionInDb> transactions) async {
    final batch = _api.db.batch();
    // ignore: avoid_function_literals_in_foreach_calls
    transactions.forEach((trn) => batch.insert(_trnTable.title, _trnTable.fromModel(trn)));

    await batch.commit(noResult: true, continueOnError: true);
  }

  Future<String> transactionsToCsv([String separator = ',']) async {
    final csvHeader = _trnTable.columns.map((col) => col.title.toCamelCase()).toList();
    final transactions = await getTransactions();

    final csvData = transactions.map((trn) => _trnTable.fromModel(trn).values.toList()).toList();

    // return const ListToCsvConverter().convert([csvHeader, ...csvData], fieldDelimiter: separator);
    return Csv(fieldDelimiter: separator).encode([csvHeader, ...csvData]);
  }
}
