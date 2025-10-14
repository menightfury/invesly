import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';

class AmcRepository {
  AmcRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  AmcTable get _amcTable => _api.amcTable;

  /// Get all amcs matched by query
  Future<List<InveslyAmc>> getAmcs(String searchQuery, [int limit = 10]) async {
    final list = await _api
        .select(_amcTable)
        .where([
          SingleValueTableFilter<String>(
            _amcTable.nameColumn,
            searchQuery,
            operator: SingleValueTableFilterOperator.like,
          ),
        ])
        .toList(limit: limit);

    return list.map<InveslyAmc>((el) => InveslyAmc.fromDb(_amcTable.encode(el))).toList();
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
