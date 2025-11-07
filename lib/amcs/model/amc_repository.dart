import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';

class AmcRepository {
  // singleton api instance
  static AmcRepository? _instance;
  static AmcRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory AmcRepository(InveslyApi api) {
    _instance ??= AmcRepository._(api);
    return _instance!;
  }
  const AmcRepository._(this._api);

  final InveslyApi _api;

  AmcTable get _amcTable => _api.amcTable;

  static const String _stockUrl =
      'https://www.nseindia.com/api/historical/cm/equity?symbol=ADANIENSOL&from=20-10-2025&to=23-10-2025';
  static const String _mfUrl = 'api.mfapi.in';

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
    final dbResults = dbData.map<InveslyAmc>((e) => InveslyAmc.fromDb(_amcTable.encode(e))).toList();

    // get results from url
    final webResults = <InveslyAmc>[];
    if (genre == AmcGenre.stock) {
      // fetch stock amcs from NSE
    } else if (genre == AmcGenre.mf) {
      final response = await http.get(Uri.https(_mfUrl, 'mf/search', {'q': searchQuery}));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List<dynamic>;
        final data = jsonData
            .map<InveslyAmc>(
              (e) => InveslyAmc(id: (e['schemeCode'] as int).toString(), name: e['schemeName'] as String),
            )
            .toList();
        webResults.addAll(data);
      }
    }
    // remove duplicates
    final dbResultIds = dbResults.map((e) => e.id).toSet();
    webResults.removeWhere((e) => dbResultIds.contains(e.id));
    return [...dbResults, ...webResults];
  }

  /// Get amc by id
  Future<InveslyAmc?> getAmcById(String id) async {
    final list = await _api.select(_amcTable).where([SingleValueTableFilter<String>(_amcTable.idColumn, id)]).toList();

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.encode(list.first));
  }

  /// Get amc by name
  Future<InveslyAmc?> getAmcByName(String name) async {
    final list = await _api.select(_amcTable).where([
      SingleValueTableFilter<String>(_amcTable.nameColumn, name),
    ]).toList();

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.encode(list.first));
  }

  /// Get amc by id or name
  Future<InveslyAmc?> getAmc(String value) async {
    final list = await _api.select(_amcTable).where([
      SingleValueTableFilter<String>(_amcTable.idColumn, value),
      SingleValueTableFilter<String>(_amcTable.nameColumn, value),
    ], isAnd: false).toList();

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.encode(list.first));
  }

  /// Add or update amc
  Future<void> saveAmc(InveslyAmc amc, [bool isNew = true]) async {
    if (isNew) {
      await _api.insert(_amcTable, amc);
    } else {
      await _api.update(_amcTable, amc);
    }
  }
}
