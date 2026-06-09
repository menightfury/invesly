import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class AmcStatRepository {
  // singleton api instance
  static AmcStatRepository? _instance;
  static AmcStatRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory AmcStatRepository.initialize(InveslyApi api) {
    _instance ??= AmcStatRepository._(api);
    return _instance!;
  }
  AmcStatRepository._(this._api);

  final InveslyApi _api;

  StatTable get _statTable => _api.statTable;
  AmcTable get _amcTable => _api.amcTable;
  TransactionTable get _trnTable => _api.trnTable;

  Stream<TableEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.table == _trnTable);
  }

  /// Get statistics of all AMCs
  Future<List<InveslyStat>> getAllStats() async {
    try {
      final result = await _api
          .select(_trnTable, [
            _trnTable.accountIdColumn,
            ..._amcTable.columns,
            _trnTable.idColumn.count('num_transactions'),
            _trnTable.amountColumn.sum(
              'total_invested',
              SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.greaterThan),
            ),
            _trnTable.amountColumn.sum(
              'total_redeemed',
              SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.lessThan),
            ),
            _trnTable.quantityColumn.sum('total_quantity'),
          ])
          .join([_amcTable])
          //.where([SingleValueTableFilter<String>(_trnTable.accountIdColumn, accountId)])
          .groupBy([_trnTable.accountIdColumn, _amcTable.idColumn])
          .toList();
      final stats = result.map<InveslyStat>((map) {
        return InveslyStat(
          accountId: map[_trnTable.accountIdColumn.title] as int,
          amc: InveslyAmc.fromDb(_amcTable.fromMap(map)),
          numTransactions: map['num_transactions'] as int,
          totalQuantity: (map['total_quantity'] as num).toDouble(),
          totalInvested: (map['total_invested'] as num).toDouble(),
          totalRedeemed: (map['total_redeemed'] as num).toDouble(),
        );
      }).toList();
      return stats;
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
      // stats = List<TransactionStat>.empty();
    }
  }

  /// Get statistics of all AMCs
  Future<List<InveslyStat>> getStats(int accountId) async {
    try {
      final result = await _api
          .select(_trnTable, [
            ..._amcTable.columns,
            _trnTable.idColumn.count('num_transactions'),
            _trnTable.amountColumn.sum(
              'total_invested',
              SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.greaterThan),
            ),
            _trnTable.amountColumn.sum(
              'total_redeemed',
              SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.lessThan),
            ),
            _trnTable.quantityColumn.sum('total_quantity'),
          ])
          .join([_amcTable])
          .where([SingleValueTableFilter<int>(_trnTable.accountIdColumn, accountId)])
          .groupBy([_amcTable.idColumn])
          .toList();
      final stats = result.map<InveslyStat>((map) {
        return InveslyStat(
          accountId: accountId,
          amc: InveslyAmc.fromDb(_amcTable.fromMap(map)),
          numTransactions: map['num_transactions'] as int,
          totalQuantity: (map['total_quantity'] as num).toDouble(),
          totalInvested: (map['total_invested'] as num).toDouble(),
          totalRedeemed: (map['total_redeemed'] as num).toDouble(),
        );
      }).toList();
      return stats;
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
      // stats = List<TransactionStat>.empty();
    }
  }

  /// Get statistics of AMC
  Future<InveslyStat?> getStat({required int accountId, required String amcId}) async {
    try {
      final result = await _api
          .select(_trnTable, [
            ..._amcTable.columns,
            _trnTable.idColumn.count('num_transactions'),
            _trnTable.amountColumn.sum(
              'total_invested',
              SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.greaterThan),
            ),
            _trnTable.amountColumn.sum(
              'total_redeemed',
              SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.lessThan),
            ),
            _trnTable.quantityColumn.sum('total_quantity'),
          ])
          .join([_amcTable])
          .where([
            SingleValueTableFilter<int>(_trnTable.accountIdColumn, accountId),
            SingleValueTableFilter<String>(_amcTable.idColumn, amcId),
          ])
          .toList();

      if (result.isEmpty) return null;

      final first = result.first;
      return InveslyStat(
        accountId: accountId,
        amc: InveslyAmc.fromDb(_amcTable.fromMap(first)),
        numTransactions: first['num_transactions'] as int,
        totalQuantity: (first['total_quantity'] as num).toDouble(),
        totalInvested: (first['total_invested'] as num).toDouble(),
        totalRedeemed: (first['total_redeemed'] as num).toDouble(),
      );
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
    }
  }

  Future<void> close() => _api.close();
}
