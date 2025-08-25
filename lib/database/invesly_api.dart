import 'dart:async';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
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
  // preventing from calling the class
  // InveslyApi._({required this.db, required this.tables});

  // final Database db;
  // final List<TableSchema> tables;

  Database? _db;
  Database get db {
    assert(_db != null, 'Please make sure to initialize before getting database');
    return _db!;
  }

  final List<TableSchema> _tables = [];

  // Stream of TableChangeEvent
  Stream<TableChangeEvent> get onTableChange => _tableChangeEventController.stream;

  // static InveslyApi? _instance;
  // static InveslyApi get instance {
  //   assert(_instance != null, 'No instance found, please make sure to initialize before getting instance');
  //   return _instance!;
  // }

  String get dbPath => p.join(databaseDirectory.path, 'invesly.db');

  Future<void> initializeDatabase() async {
    // if (_instance != null) return _instance!;

    _db = await openDatabase(dbPath, version: 1);

    // initialize all necessary tables
    // final accountTable = AccountTable();
    // final amcTable = AmcTable();
    // final trnTable = TransactionTable();
    _tables.addAll([AccountTable(), AmcTable(), TransactionTable()]);
    // return _instance = InveslyApi._(db: db, tables: [accountTable, amcTable, trnTable]);
  }

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() => _tables.firstWhereOrNull((table) => table is T) as T?;

  // Table getters
  AccountTable get accountTable => getTable<AccountTable>()!;
  AmcTable get amcTable => getTable<AmcTable>()!;
  TransactionTable get trnTable => getTable<TransactionTable>()!;

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
