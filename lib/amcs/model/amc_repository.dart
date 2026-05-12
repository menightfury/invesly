import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/amc_stat_model.dart';
import 'package:invesly/amcs/model/latest_price_model.dart';
import 'package:invesly/amcs/model/latest_xirr_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

class AmcRepository {
  // singleton api instance
  static AmcRepository? _instance;
  static AmcRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory AmcRepository.initialize(InveslyApi api) {
    _instance ??= AmcRepository._(api);
    return _instance!;
  }
  AmcRepository._(this._api);

  final InveslyApi _api;

  AmcTable get _amcTable => _api.amcTable;
  TransactionTable get _trnTable => _api.trnTable;

  /// Get all amcs - Remove this method in production
  Future<List<InveslyAmc>> getAllAmcs() async {
    final dbData = await _api.select(_amcTable).toList();
    return dbData.map<InveslyAmc>((e) => InveslyAmc.fromDb(_amcTable.fromMap(e))).toList();
  }

  /// Get all amcs matched by query
  Future<List<InveslyAmc>> getAmcs(String searchQuery, AmcGenre genre, [int limit = 10]) async {
    // get results from db
    final dbData = await _api
        .select(_amcTable)
        .where([
          SingleValueTableFilter<String>(_amcTable.genreColumn, genre.name, operator: FilterOperator.equal),
          SingleValueTableFilter<String>(_amcTable.nameColumn, searchQuery, operator: FilterOperator.like),
        ])
        .toList(limit: limit);
    final dbResults = dbData.map<InveslyAmc>((e) => InveslyAmc.fromDb(_amcTable.fromMap(e))).toList();
    return dbResults;
  }

  /// Get amc by id
  Future<InveslyAmc?> getAmcById(String id) async {
    final list = await _api.select(_amcTable).where([SingleValueTableFilter<String>(_amcTable.idColumn, id)]).toList();

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.fromMap(list.first));
  }

  /// Get amc by name
  Future<InveslyAmc?> getAmcByName(String name) async {
    final list = await _api.select(_amcTable).where([
      SingleValueTableFilter<String>(_amcTable.nameColumn, name),
    ]).toList();

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.fromMap(list.first));
  }

  /// Get amc by id or name
  Future<InveslyAmc?> getAmc(String value) async {
    final list = await _api.select(_amcTable).where([
      SingleValueTableFilter<String>(_amcTable.idColumn, value),
      SingleValueTableFilter<String>(_amcTable.nameColumn, value),
    ], isAnd: false).toList();

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.fromMap(list.first));
  }

  /// Add or update amc
  Future<void> saveAmc(InveslyAmc amc, {bool isNew = true}) async {
    if (isNew) {
      await _api.insert(_amcTable, amc);
      // await _api.table(_amcTable).insert(amc)
    } else {
      await _api.update(_amcTable, amc);
    }
  }

  /// Add or update multiple amcs
  Future<void> saveAmcs(List<AmcInDb> amcs) async {
    final batch = _api.db.batch();
    for (var amc in amcs) {
      batch.insert(_amcTable.tableName, _amcTable.fromModel(amc), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true, continueOnError: true);
  }

  /// Fetch amcs from network
  Future<List<AmcInDb>?> getAmcsFromNetwork(http.Client client, String uri) async {
    final response = await client.get(Uri.parse(uri));

    if (response.statusCode != 200 && response.body.isEmpty) return null;

    // If the server did return a 200 OK response, parse the JSON.
    // Use the compute function to run parse in a separate isolate.
    return compute<String, List<AmcInDb>>((body) {
      final parsed = (jsonDecode(body) as List<Object?>).cast<Map<String, dynamic>>();
      return parsed.map<AmcInDb>(AmcTable.instance.fromMap).toList();
    }, response.body);
  }

  /// Get latest price for an AMC
  Future<LatestPrice?> getLatestPrice(InveslyAmc amc) async {
    // if latest price is not available or is outdated, fetch from network
    final uri = amc.latestPriceUri;
    if (uri == null) return null;

    LatestPrice? ltp = amc.ltp;
    // if latest price is available and is fetched today, return it
    if (ltp?.fetchDate.isToday ?? false) {
      return amc.ltp;
    }

    final client = http.Client();
    try {
      final response = await client.get(Uri.parse(uri));

      if (response.statusCode != 200 && response.body.isEmpty) {
        return null;
      }

      // If the server did return a 200 OK response, parse the JSON.
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      ltp = amc.fromLtpMap(parsed);
      if (ltp != null) {
        saveLatestPrice(amc, ltp);
      }
    } catch (err) {
      $logger.e(err);
    }
    return ltp;
  }

  /// Save latest price for an AMC
  Future<void> saveLatestPrice(InveslyAmc amc, LatestPrice ltp) async {
    final updatedAmc = amc.copyWith(ltp: ltp);
    await saveAmc(updatedAmc, isNew: false);
  }

  /// Save xirr for an AMC
  Future<void> saveXirr(InveslyAmc amc, LatestXirr xirr) async {
    final updatedAmc = amc.copyWith(xirr: xirr);
    await saveAmc(updatedAmc, isNew: false);
  }

  /// Get statistics of an AMC
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
}
