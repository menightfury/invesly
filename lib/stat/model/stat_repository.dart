import 'dart:async';

import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';

class StatRepository {
  // singleton api instance
  static StatRepository? _instance;
  static StatRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory StatRepository.initialize(InveslyApi api) {
    _instance ??= StatRepository._(api);
    return _instance!;
  }
  StatRepository._(this._api);

  final InveslyApi _api;

  StatTable get _statTable => _api.statTable;
  AmcTable get _amcTable => _api.amcTable;
  // TransactionTable get _trnTable => _api.trnTable;
  // AccountTable get _accountTable => _api.accountTable;

  Stream<TableEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.table == _statTable);
  }

  /// Fetch statistics of all AMCs, including initial data and updates on table changes.
  Stream<List<InveslyStat>> fetchAllStats() async* {
    yield await getAllStats();
    await for (final _ in onDataChanged) {
      yield await getAllStats();
    }
  }

  /// Get statistics of all AMCs
  Future<List<InveslyStat>> getAllStats() async {
    try {
      // final result = await _api.select(
      //   _trnTable,
      //   join: [_amcTable],
      //   columns: [
      //     _trnTable.accountIdColumn,
      //     ..._amcTable.columns,
      //     _trnTable.idColumn.count('num_transactions'),
      //     _trnTable.amountColumn.sum(
      //       'total_invested',
      //       SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.greaterThan),
      //     ),
      //     _trnTable.amountColumn.sum(
      //       'total_redeemed',
      //       SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.lessThan),
      //     ),
      //     _trnTable.quantityColumn.sum('total_quantity'),
      //   ],
      //   groupBy: [_trnTable.accountIdColumn, _amcTable.idColumn],
      // );
      final result = await _api.select(_statTable, join: [_amcTable]);

      final stats = result.map<InveslyStat>((map) {
        return InveslyStat.fromDb(
          _statTable.fromMap(map),
          _amcTable.fromMap(map[_amcTable.type.toString().toCamelCase()] as Map<String, dynamic>),
        );
      }).toList();
      return stats;
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
    }
  }

  /// Get statistics of all AMCs
  Future<List<InveslyStat>> getStats(int accountId) async {
    try {
      // final result = await _api.select(
      //   _trnTable,
      //   join: [_amcTable],
      //   columns: [
      //     ..._amcTable.columns,
      //     _trnTable.idColumn.count('num_transactions'),
      //     _trnTable.amountColumn.sum(
      //       'total_invested',
      //       SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.greaterThan),
      //     ),
      //     _trnTable.amountColumn.sum(
      //       'total_redeemed',
      //       SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.lessThan),
      //     ),
      //     _trnTable.quantityColumn.sum('total_quantity'),
      //   ],
      //   filter: SingleValueTableFilter<int>(_trnTable.accountIdColumn, accountId),
      //   groupBy: [_amcTable.idColumn],
      // );
      final result = await _api.select(
        _statTable,
        join: [_amcTable],
        filter: SingleValueTableFilter<int>(_statTable.accountIdColumn, accountId),
      );
      final stats = result.map<InveslyStat>((map) {
        return InveslyStat.fromDb(
          _statTable.fromMap(map),
          _amcTable.fromMap(map[_amcTable.type.toString().toCamelCase()] as Map<String, dynamic>),
        );
      }).toList();
      return stats;
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
    }
  }

  /// Get statistics of AMC
  Future<InveslyStat?> getStat({required int accountId, required String amcId}) async {
    try {
      // final result = await _api.select(
      //   _trnTable,
      //   join: [_amcTable],
      //   columns: [
      //     ..._amcTable.columns,
      //     _trnTable.idColumn.count('num_transactions'),
      //     _trnTable.amountColumn.sum(
      //       'total_invested',
      //       SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.greaterThan),
      //     ),
      //     _trnTable.amountColumn.sum(
      //       'total_redeemed',
      //       SingleValueTableFilter<num>(_trnTable.amountColumn, 0, operator: FilterOperator.lessThan),
      //     ),
      //     _trnTable.quantityColumn.sum('total_quantity'),
      //   ],
      //   filter: TableFilterGroup([
      //     SingleValueTableFilter<int>(_trnTable.accountIdColumn, accountId),
      //     SingleValueTableFilter<String>(_amcTable.idColumn, amcId),
      //   ]),
      // );

      final result = await _api.select(
        _statTable,
        join: [_amcTable],
        filter: TableFilterGroup([
          SingleValueTableFilter<int>(_statTable.accountIdColumn, accountId),
          SingleValueTableFilter<String>(_statTable.amcIdColumn, amcId),
        ]),
      );

      if (result.isEmpty) return null;

      final first = result.first;
      return InveslyStat.fromDb(
        _statTable.fromMap(first),
        _amcTable.fromMap(first[_amcTable.type.toString().toCamelCase()] as Map<String, dynamic>),
      );
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
    }
  }

  /// Save latest xirr
  // Future<void> saveXirr(StatInDb stat, double xirr) async {
  //   final updatedStat = stat.copyWith(xirr: xirr);
  //   await _api.update(_statTable, updatedStat);
  // }

  /// Save updated stat
  Future<void> saveStat(StatInDb stat) async {
    await _api.update(_statTable, stat);
  }

  Future<void> close() => _api.close();
}
