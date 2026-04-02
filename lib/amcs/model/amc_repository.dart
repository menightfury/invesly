import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';

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
  const AmcRepository._(this._api);

  final InveslyApi _api;

  AmcTable get _amcTable => _api.amcTable;

  /// Get all amcs
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
  Future<void> saveAmc(InveslyAmc amc, [bool isNew = true]) async {
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
    if (amc.genre == null) return null;

    final uri = amc.latestPriceUri;
    if (uri == null) return null;

    final client = http.Client();
    try {
      final response = await client.get(Uri.parse(uri));

      if (response.statusCode != 200 && response.body.isEmpty) {
        return null;
      }

      // If the server did return a 200 OK response, parse the JSON.
      final parsed = jsonDecode(response.body) as Map<String, dynamic>;
      return amc.toLatestPrice(parsed);
    } catch (e) {
      throw ('Error fetching current AMC price: $e');
    }
  }
}

class LatestPrice {
  final AmcInDb amc;
  final DateTime date;
  final double? price;

  const LatestPrice({required this.amc, required this.date, required this.price});

  // static String? uri(InveslyAmc amc) {
  //   return switch (amc.genre) {
  //     AmcGenre.mf => 'https://api.mfapi.in/mf/${amc.code}/latest',
  //     AmcGenre.stock => 'https://www.nseindia.com/api/quote-equity?symbol=${amc.code}',
  //     _ => null,
  //   };
  // }

  // factory LatestPrice.fromMfMap(Map<String, dynamic> map) {
  //   final now = DateTime.now();
  //   // {
  //   //   "meta": {
  //   //     "fund_house": "Motilal Oswal Mutual Fund",
  //   //     "scheme_type": "Open Ended Schemes",
  //   //     ...
  //   //   },
  //   //   "data": [
  //   //     {
  //   //       "date": "16-01-2026",
  //   //       "nav": "112.07910"
  //   //     }
  //   //   ],
  //   //   "status": "SUCCESS"
  //   // }
  //   final data = (map['data'] as List<Object?>?)?.cast<Map<String, dynamic>>();
  //   if (data == null || data.isEmpty) {
  //     return LatestPrice(date: now, price: null);
  //   }

  //   final latestEntry = data.first;
  //   final dateParts = latestEntry['date'].toString().split('-');
  //   final date = DateTime(
  //     int.tryParse(dateParts.length > 2 ? dateParts[2] : '') ?? now.year,
  //     int.tryParse(dateParts.length > 1 ? dateParts[1] : '') ?? now.month,
  //     int.tryParse(dateParts.isNotEmpty ? dateParts[0] : '') ?? now.day,
  //   );
  //   final nav = double.tryParse(latestEntry['nav'].toString());
  //   return LatestPrice(date: date, price: nav);
  // }

  // factory LatestPrice.fromStockMap(Map<String, dynamic> map) {
  //   // {
  //   // ...
  //   //   "priceInfo": {
  //   //       "lastPrice": 1168.4,
  //   //       "change": -36.799999999999955,
  //   //       "pChange": -3.053435114503813,
  //   //       "previousClose": 1205.2,
  //   //       "open": 1185.1,
  //   //       "close": 1161.3,
  //   //       "basePrice": 1205.2,
  //   //       ...
  //   //   },
  //   // ...
  //   // }
  //   final priceInfo = map['priceInfo'] as Map<String, dynamic>?;
  //   final price = priceInfo != null ? double.tryParse(priceInfo['lastPrice']?.toString() ?? '') : null;
  //   final date = DateTime.now();
  //   return LatestPrice(date: date, price: price);
  // }
}

// class LatestStockPrice extends LatestPrice {
//   const LatestStockPrice({required super.date, super.price});
// }

// class LatestMfPrice extends LatestPrice {
//   final double? nav;
//   const LatestMfPrice({required super.date, this.nav}) : super(price: nav);
// }
