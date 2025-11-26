import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

  // static const String _stockUrl =
  //     'https://www.nseindia.com/api/historical/cm/equity?symbol=ADANIENSOL&from=20-10-2025&to=23-10-2025';
  // static const String _mfUrl = 'api.mfapi.in';

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

    // get results from url
    final webResults = <InveslyAmc>[];
    final snap = await FirebaseFirestore.instance
        .collection('${genre.name}s')
        .orderBy('name')
        .startAt([searchQuery])
        .endAt(['$searchQuery\uf8ff'])
        .get();

    for (var doc in snap.docs) {
      final data = doc.data()
        ..putIfAbsent('id', () => doc.id)
        ..putIfAbsent('genre', () => genre.index);
      final amc = InveslyAmc.fromDb(_amcTable.fromMap(data));
      webResults.add(amc);
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
    } else {
      await _api.update(_amcTable, amc);
    }
  }

  /// Fetch amcs from network
  Future<List<Photo>> _fetchAmcsFromNetwork(http.Client client) async {
    final response = await client.get(
      Uri.parse('https://api.github.com/repos/menightfury/invesly-data/contents/amcs.json'),
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      // If the server did return a 200 OK response, parse the JSON.
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final sha = decoded['sha'] as String;
      final amcResponse = await client.get(Uri.parse(decoded['download_url'] as String));

      // Use the compute function to run parsePhotos in a separate isolate.
      return compute(_parseAmcs, amcResponse.body);
    }
  }

  List<AmcInDb> _parseAmcs(String responseBody) {
    final parsed = (jsonDecode(responseBody) as List<Object?>).cast<Map<String, Object?>>();

    return parsed.map<AmcInDb>(AmcInDb.fromJson).toList();
  }
}
