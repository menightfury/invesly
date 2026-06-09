import 'dart:async';
import 'dart:io';
import 'package:invesly/amc_stat/model/amc_stat_model.dart';
import 'package:path/path.dart' as p;

import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

import 'table_schema.dart';

class InveslyApi {
  final Directory databaseDirectory;
  final StreamController<TableEvent> _tableEventController;

  InveslyApi(this.databaseDirectory) : _tableEventController = StreamController<TableEvent>.broadcast();

  Database? _db;
  Database get db {
    assert(_db != null, 'Please make sure to initialize before getting database');
    return _db!;
  }

  final List<TableSchema> _tables = [];

  // Stream of TableChangeEvent
  Stream<TableEvent> get onTableChange => _tableEventController.stream;

  String get dbPath => p.join(databaseDirectory.path, 'invesly.db');

  // define all necessary tables
  final _accountTable = AccountTable();
  final _amcTable = AmcTable();
  final _trnTable = TransactionTable();
  final _statTable = StatTable();

  // Table getters
  AccountTable get accountTable => _accountTable;
  AmcTable get amcTable => _amcTable;
  TransactionTable get trnTable => _trnTable;
  StatTable get statTable => _statTable;

  Future<void> initializeDatabase() async {
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        final batch = db.batch();
        // initialize all necessary tables in database
        batch.execute(_accountTable.createTable());
        batch.execute(_amcTable.createTable());
        batch.execute(_trnTable.createTable());
        batch.execute(_statTable.createTable());
        // create triggers for automatic stats updates
        batch.execute(_createInsertTrigger());
        batch.execute(_createUpdateTrigger());
        batch.execute(_createDeleteTrigger());
        
        await batch.commit(noResult: true, continueOnError: true);
      },
    );

    // ?? Close database at the end ??
    _tables.addAll([_accountTable, _amcTable, _trnTable, _statTable]);
  }

  String _createInsertTrigger() => '''
    CREATE TRIGGER IF NOT EXISTS trn_insert_trigger
    AFTER INSERT ON transactions
    FOR EACH ROW
    BEGIN
      INSERT OR IGNORE INTO stats (account_id, amc_id, num_transactions, total_quantity, total_invested, total_redeemed)
      VALUES (NEW.account_id, NEW.amc_id, 0, 0.0, 0.0, 0.0);

      UPDATE stats SET
        num_transactions = num_transactions + 1,
        total_quantity = total_quantity + COALESCE(NEW.quantity, 0),
        total_invested = CASE WHEN NEW.total_amount > 0 THEN total_invested + NEW.total_amount ELSE total_invested END,
        total_redeemed = CASE WHEN NEW.total_amount < 0 THEN total_redeemed + ABS(NEW.total_amount) ELSE total_redeemed END
      WHERE account_id = NEW.account_id AND amc_id = NEW.amc_id;
    END;
  ''';

  String _createUpdateTrigger() => '''
    CREATE TRIGGER IF NOT EXISTS trn_update_trigger
    AFTER UPDATE ON transactions
    FOR EACH ROW
    BEGIN
      UPDATE stats SET
        total_quantity = total_quantity - COALESCE(OLD.quantity, 0) + COALESCE(NEW.quantity, 0),
        total_invested = CASE
          WHEN OLD.total_amount > 0 AND NEW.total_amount > 0 THEN total_invested - OLD.total_amount + NEW.total_amount
          WHEN OLD.total_amount > 0 AND NEW.total_amount <= 0 THEN total_invested - OLD.total_amount
          WHEN OLD.total_amount <= 0 AND NEW.total_amount > 0 THEN total_invested + NEW.total_amount
          ELSE total_invested
        END,
        total_redeemed = CASE
          WHEN OLD.total_amount < 0 AND NEW.total_amount < 0 THEN total_redeemed - ABS(OLD.total_amount) + ABS(NEW.total_amount)
          WHEN OLD.total_amount < 0 AND NEW.total_amount >= 0 THEN total_redeemed - ABS(OLD.total_amount)
          WHEN OLD.total_amount >= 0 AND NEW.total_amount < 0 THEN total_redeemed + ABS(NEW.total_amount)
          ELSE total_redeemed
        END
      WHERE account_id = NEW.account_id AND amc_id = NEW.amc_id;
    END;
  ''';

  String _createDeleteTrigger() => '''
    CREATE TRIGGER IF NOT EXISTS trn_delete_trigger
    AFTER DELETE ON transactions
    FOR EACH ROW
    BEGIN
      UPDATE stats SET
        num_transactions = MAX(0, num_transactions - 1),
        total_quantity = total_quantity - COALESCE(OLD.quantity, 0),
        total_invested = CASE WHEN OLD.total_amount > 0 THEN total_invested - OLD.total_amount ELSE total_invested END,
        total_redeemed = CASE WHEN OLD.total_amount < 0 THEN total_redeemed - ABS(OLD.total_amount) ELSE total_redeemed END
      WHERE account_id = OLD.account_id AND amc_id = OLD.amc_id;
    END;
  ''';

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() => _tables.firstWhereOrNull((table) => table is T) as T?;

  TableQueryBuilder select(TableSchema table, [List<TableColumnBase>? columns]) {
    return TableQueryBuilder(db: db, table: table, columns: columns);
  }

  Future<int> insert(TableSchema table, TableDataModel data) async {
    final r = await db.insert(table.tableName, table.fromModel(data));
    _tableEventController.add(TableEvent(table, TableEventType.inserted, data));
    return r;
  }

  Future<int> update(TableSchema table, TableDataModel data) async {
    final r = await db.update(
      table.tableName,
      table.fromModel(data),
      where: '${table.idColumn.fullTitle} = ?',
      whereArgs: [data.id],
    );
    _tableEventController.add(TableEvent(table, TableEventType.updated, data));
    return r;
  }

  Future<int> delete(TableSchema table, TableDataModel data) async {
    final r = await Future.delayed(2.seconds, () => 1); // TODO: implement
    _tableEventController.add(TableEvent(table, TableEventType.deleted, data));
    return r;
  }

  Future<void> close() async {
    await _db?.close();
    await _tableEventController.close();
  }
}
