import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/data_access_object.dart';
import 'package:invesly/database/invesly_api.dart';

class AmcRepository extends DataAccessObject<AmcInDb> {
  AmcRepository(InveslyApi api) : super(db: api.db, table: api.amcTable);

  /// Get all amcs matched by query
  Future<List<InveslyAmc>> getAmcs() async {
    final list = await select().toList();

    return list.map<InveslyAmc>((el) => InveslyAmc.fromDb(table.encode(el))).toList();
  }

  /// Get amc by Id
  Future<InveslyAmc?> getAmc(String id) async {
    // return _api.getAmc(id);
    final list = await select().where({table.idColumn: id}).toList(); // TODO: fix this

    if (list.isEmpty) return null;

    return InveslyAmc.fromDb(table.encode(list.first));
  }

  /// Add or update amc
  Future<void> saveAmc(InveslyAmc amc, [bool isNew = true]) async {
    if (isNew) {
      await insert(amc);
    } else {
      await update(amc);
    }
  }
}
