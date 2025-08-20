import 'package:invesly/amcs/model/amc_model.dart';
// import 'package:invesly/database/data_access_object.dart';
import 'package:invesly/database/invesly_api.dart';

// class AmcRepository extends DataAccessObject<AmcInDb> {
class AmcRepository {
  // AmcRepository(InveslyApi api) : super(db: api.db, table: api.amcTable);
  AmcRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  AmcTable get _amcTable => _api.amcTable;

  /// Get all amcs matched by query
  Future<List<InveslyAmc>> getAmcs() async {
    final list = await _api.select(_amcTable).toList();

    return list.map<InveslyAmc>((el) => InveslyAmc.fromDb(_amcTable.encode(el))).toList();
  }

  /// Get amc by Id
  Future<InveslyAmc?> getAmc(String id) async {
    // return _api.getAmc(id);
    final list = await _api.select(_amcTable).where({_amcTable.idColumn: id}).toList(); // TODO: fix this

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
