import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/accounts/model/account_model.dart';

import 'table_schema.dart';

class InveslyApi {
  final Directory databaseDirectory;
  final StreamController<TableChangeEvent> _tableChangeEventController;

  InveslyApi(this.databaseDirectory) : _tableChangeEventController = StreamController<TableChangeEvent>.broadcast();

  Database? _db;
  Database get db {
    assert(_db != null, 'Please make sure to initialize before getting database');
    return _db!;
  }

  final List<TableSchema> _tables = [];

  // Stream of TableChangeEvent
  Stream<TableChangeEvent> get onTableChange => _tableChangeEventController.stream;

  String get dbPath => p.join(databaseDirectory.path, 'invesly.db');

  // define all necessary tables
  final _accountTable = AccountTable();
  final _amcTable = AmcTable();
  final _trnTable = TransactionTable();

  // Table getters
  AccountTable get accountTable => _accountTable;
  AmcTable get amcTable => _amcTable;
  TransactionTable get trnTable => _trnTable;

  Future<void> initializeDatabase() async {
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.transaction((txn) async {
          // intialize all necessary tables in database
          await txn.execute(_accountTable.schema);
          await txn.execute(_amcTable.schema);
          await txn.execute(_trnTable.schema);
        });
      },
    );

    _tables.addAll([_accountTable, _amcTable, _trnTable]);
  }

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() => _tables.firstWhereOrNull((table) => table is T) as T?;

  TableQueryBuilder select(TableSchema table, [List<TableColumnBase>? columns]) {
    return TableQueryBuilder(db: db, table: table, columns: columns);
  }

  Future<int> insert(TableSchema table, InveslyDataModel data) async {
    final r = await db.insert(table.name, table.decode(data));
    _tableChangeEventController.add(TableChangeEvent(table, TableChangeEventType.insertion));
    return r;
  }

  Future<int> update(TableSchema table, InveslyDataModel data) async {
    final r = await db.update(
      table.name,
      table.decode(data),
      where: '${table.idColumn.fullTitle} = ?',
      whereArgs: [data.id],
    );
    _tableChangeEventController.add(TableChangeEvent(table, TableChangeEventType.updation));
    return r;
  }

  Future<int> delete(TableSchema table, InveslyDataModel data) async {
    final r = await Future.delayed(2.seconds, () => 1); // TODO: implement
    _tableChangeEventController.add(TableChangeEvent(table, TableChangeEventType.deletion));
    return r;
  }
}
