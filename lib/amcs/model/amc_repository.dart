import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/invesly_api.dart';

class AmcRepository {
  const AmcRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;
  AmcTable get _amcTable => _api.amcTable;

  /// Get all amcs matched by query
  Future<List<InveslyAmc>> getAmcs() async {
    final list = await _api.table(_amcTable).select().toList();

    return list.map<InveslyAmc>((el) => InveslyAmc.fromDb(_amcTable.encode(el))).toList();
  }

  /// Get amc by Id
  Future<InveslyAmc?> getAmc(String id) async {
    // return _api.getAmc(id);
    final list = await _api.table(_amcTable).select().filter({_amcTable.idColumn.title: id}).toList(); // TODO: fix this

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(_amcTable.encode(list.first));
  }

  /// Add or update amc
  Future<void> saveAmc(InveslyAmc amc, [bool isNew = true]) async {
    if (isNew) {
      await _api.table(_amcTable).insert(amc);
    } else {
      await _api.table(_amcTable).update(amc);
    }
  }
}
