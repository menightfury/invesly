import 'dart:async';

import 'package:csv/csv.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/data_access_object.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

// class TransactionRepository extends DataAccessObject<TransactionInDb> {
class TransactionRepository {
  // TransactionRepository(InveslyApi api) : _api = api, super(db: api.db, table: api.trnTable);
  TransactionRepository(this.api);

  // final InveslyApi _api;
  final InveslyApi api;

  AmcTable get _amcTable => api.amcTable;
  TransactionTable get _trnTable => api.trnTable;

  Stream<TableChangeEvent> get onDataChanged {
    return api.onTableChange.where((event) => event.table == _trnTable);
  }

  /// Get transactions
  Future<List<InveslyTransaction>> getTransactions({String? userId, String? amcId, int? showItems}) async {
    final filter = <TableColumn, String>{};
    if (userId != null) {
      filter.putIfAbsent(_trnTable.userIdColumn, () => userId);
    }

    if (amcId != null) {
      filter.putIfAbsent(_trnTable.amcIdColumn, () => amcId);
    }

    late final List<InveslyTransaction> transactions;
    try {
      final result = await api.select(_trnTable).join([_amcTable]).where(filter).toList();
      // orderBy: '${_trnTable.dateColumn.title} DESC',
      // limit: showItems,

      $logger.f(result);
      if (result.isEmpty) return List<InveslyTransaction>.empty();

      transactions =
          result.map<InveslyTransaction>((map) {
            return InveslyTransaction.fromDb(
              _trnTable.encode(map),
              _amcTable.encode(map[_amcTable.type.toString().toCamelCase()] as Map<String, dynamic>),
            );
          }).toList();
    } on Exception catch (err) {
      $logger.e(err);
      transactions = List<InveslyTransaction>.empty();
    }

    return transactions;
  }

  /// Get transaction statistics
  Future<List<TransactionStat>> getTransactionStats(String userId) async {
    final filter = {_trnTable.userIdColumn: userId};

    late final List<TransactionStat> stats;
    try {
      final result =
          await api
              .select(_trnTable, [
                _trnTable.userIdColumn.alias('user_id'),
                _amcTable.genreColumn.alias('genre'),
                _trnTable.amountColumn.sum('total_amount'),
                _trnTable.idColumn.count('num_transactions'),
              ])
              .join([_amcTable])
              .where(filter)
              .groupBy([_amcTable.genreColumn])
              .toList();
      $logger.w(result);
      stats =
          result.map<TransactionStat>((map) {
            return TransactionStat(
              userId: map['user_id'] as String,
              amcGenre: AmcGenre.getByIndex(map['genre'] as int),
              numTransactions: map['num_transactions'] as int,
              totalAmount: (map['total_amount'] as num).toDouble(),
            );
          }).toList();
    } on Exception catch (err) {
      $logger.e(err);
      stats = List<TransactionStat>.empty();
    }

    return stats;
  }

  /// Add or update a transaction
  Future<void> saveTransaction(InveslyTransaction trn, [bool isNew = true]) async {
    if (isNew) {
      await api.insert(_trnTable, trn);
    } else {
      await api.update(_trnTable, trn);
    }
  }

  Future<String> transactionsToCsv([String separator = ',']) async {
    final csvHeader = _trnTable.columns.map((col) => col.title.toCamelCase()).toList();
    final transactions = await getTransactions();

    final csvData = transactions.map((trn) => _trnTable.decode(trn).values.toList()).toList();

    return const ListToCsvConverter().convert([csvHeader, ...csvData], fieldDelimiter: separator);
  }
}
