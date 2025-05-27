import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/users/model/user_model.dart';

import 'table_schema.dart';

class InveslyApi {
  // preventing from calling the class
  InveslyApi._({required this.db, required this.tables});

  final Database db;
  final List<TableSchema> tables;

  static InveslyApi? _instance;
  static InveslyApi get instance {
    assert(_instance != null, 'No instance found, please make sure to initialize before getting instance');
    return _instance!;
  }

  static Future<InveslyApi> initialize(Directory directory) async {
    if (_instance != null) return _instance!;

    // Initialize sqlite database in that declared directory and open the database.
    final path = p.join(directory.path, 'invesly.db');

    // sqflite - copy from assets (for optimizing performance, asset is copied only once)
    final isDbExists = await databaseExists(path);
    if (!isDbExists) {
      // should happen only first time the application is launched copy from asset
      final data = await rootBundle.load('assets/data/initial.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      $logger.d('Opening existing database');
    }

    final db = await openDatabase(path, version: 1);

    // initialize all necessary tables
    final userTable = UserTable();
    final amcTable = AmcTable();
    final trnTable = TransactionTable();
    return _instance = InveslyApi._(db: db, tables: [userTable, amcTable, trnTable]);
  }

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() => tables.firstWhereOrNull((table) => table is T) as T?;

  // Table getters
  UserTable get userTable => getTable<UserTable>()!;
  AmcTable get amcTable => getTable<AmcTable>()!;
  TransactionTable get trnTable => getTable<TransactionTable>()!;
}
