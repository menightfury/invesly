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

  AmcTable get _amcTable => _api.amcTable;
  TransactionTable get _trnTable => _api.trnTable;

  Stream<TableEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.tables.contains(_trnTable));
  }

  // /// Fetch statistics of all AMCs (on initial load, on transactions change)
  // Stream<List<AmcStat>> fetchStats(String accountId) {
  //   return _api.onTableChange.where((event) => event.tables.contains(_trnTable)).asyncMap((_) async {
  //     return await getStats(accountId);
  //   });
  // }

  /// Get statistics of all AMCs
  Future<List<AmcStat>> getStats(String accountId) async {
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
          .where([SingleValueTableFilter<String>(_trnTable.accountIdColumn, accountId)])
          .groupBy([_amcTable.idColumn])
          .toList();
      final stats = result.map<AmcStat>((map) {
        return AmcStat(
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

  Future<void> close() => _api.close();
}
