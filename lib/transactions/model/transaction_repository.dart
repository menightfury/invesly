import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/data_access_object.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class TransactionRepository extends DataAccessObject<TransactionInDb> {
  TransactionRepository(InveslyApi api) : _api = api, super(db: api.db, table: api.trnTable);

  final InveslyApi _api;

  AmcTable get _amcTable => _api.amcTable;
  TransactionTable get _trnTable => table as TransactionTable;

  /// Get transactions
  Future<List<InveslyTransaction>> getTransactions({String? userId, String? amcId, int? showItems}) async {
    final filter = <String, dynamic>{};
    if (userId != null) {
      filter.putIfAbsent(_trnTable.userIdColumn.title, () => userId);
    }

    if (amcId != null) {
      filter.putIfAbsent(_trnTable.amcIdColumn.title, () => amcId);
    }

    late final List<InveslyTransaction> transactions;
    try {
      final result = await select().join([_amcTable]).filter(filter).toList();
      // orderBy: '${_trnTable.dateColumn.title} DESC',
      // limit: showItems,

      $logger.f(result);
      if (result.isEmpty) return List<InveslyTransaction>.empty();

      transactions =
          result.map<InveslyTransaction>((map) {
            return InveslyTransaction.fromDb(
              table.encode(map),
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
  Future<List<TransactionStat>> getTransactionStats() async {
    late final List<TransactionStat> stats;

    try {
      final result =
          await select([
            _trnTable.userIdColumn.alias('user_id'),
            _amcTable.genreColumn.alias('genre'),
            _trnTable.amountColumn.sum('total_amount'),
            _trnTable.idColumn.count('num_transactions'),
          ]).join([_amcTable]).groupBy([_trnTable.userIdColumn, _amcTable.genreColumn]).toList();
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
      await insert(trn);
    } else {
      await update(trn);
    }
  }
}
