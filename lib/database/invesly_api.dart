import 'dart:async';
import 'dart:io';
import 'package:invesly/stat/model/stat_model.dart';
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
    final tables = <TableSchema>[_accountTable, _amcTable, _trnTable, _statTable];
    _db = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        final batch = db.batch();

        // initialize all necessary tables in database
        for (final table in tables) {
          batch.execute(table.createTableSql);
        }

        // create triggers for automatic stats updates (dynamically generated)
        batch.execute(
          _trnTable.createTrigger(
            eventType: TableEventType.insert,
            operation: _buildTriggerOperation(TableEventType.insert),
          ),
        );
        batch.execute(
          _trnTable.createTrigger(
            eventType: TableEventType.update,
            operation: _buildTriggerOperation(TableEventType.update),
          ),
        );
        batch.execute(
          _trnTable.createTrigger(
            eventType: TableEventType.delete,
            operation: _buildTriggerOperation(TableEventType.delete),
          ),
        );

        await batch.commit(noResult: true, continueOnError: true);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await _migrateAccountsToNewModel(db);
        }
      },
    );

    // ?? Close database at the end ??
    _tables.addAll(tables);
  }

  Future<void> _migrateAccountsToNewModel(Database db) async {
    final accountTable = _accountTable;
    final columns = await db.rawQuery('PRAGMA table_info(${accountTable.title})');
    final existingColumns = columns.map((column) => column['name'] as String).toSet();
    final newColumns = _accountTable.columns.map((column) => column.title).toSet();
    final commonColumns = existingColumns.intersection(newColumns).join(', ');

    final batch = db.batch();
    db.execute('''
      PRAGMA foreign_keys = 0; -- setting foreign_keys off temporarily
      CREATE TABLE sqliteinvesly_temp_table AS SELECT * FROM ${accountTable.title};
      DROP TABLE ${accountTable.title};

      ${accountTable.createTableSql};
      INSERT INTO ${accountTable.title} ($commonColumns) SELECT $commonColumns FROM sqliteinvesly_temp_table;

      DROP TABLE sqliteinvesly_temp_table;
      PRAGMA foreign_keys = 1;
    ''');

    await batch.commit(noResult: true, continueOnError: true);
  }

  // Build trigger operation SQL dynamically using schema column names
  String _buildTriggerOperation(TableEventType eventType) {
    final stat = _statTable;
    final accId = stat.accountIdColumn.title;
    final amcId = stat.amcIdColumn.title;
    final numTx = stat.numTrnsColumn.title;
    final qty = stat.totalQntyColumn.title;
    final invested = stat.totalInvestedColumn.title;
    final redeemed = stat.totalRedeemedColumn.title;
    final xirr = stat.xirrColumn.title;

    final trn = _trnTable;
    final trnQty = trn.quantityColumn.title;
    final trnAmt = trn.amountColumn.title;
    final trnAccId = trn.accountIdColumn.title;
    final trnAmcId = trn.amcIdColumn.title;

    return switch (eventType) {
      TableEventType.insert =>
        '''
          INSERT OR IGNORE INTO ${stat.title} ($accId, $amcId, $numTx, $qty, $invested, $redeemed)
          VALUES (NEW.$trnAccId, NEW.$trnAmcId, 1, NEW.$trnQty, IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0), IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0))
          ON CONFLICT($accId, $amcId) DO
          UPDATE SET
            $numTx = $numTx + 1,
            $qty = $qty + COALESCE(NEW.$trnQty, 0),
            $invested = $invested + IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0),
            $redeemed = $redeemed + IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0),
            $xirr = NULL; -- reset xirr to be recalculated later
        ''',

      TableEventType.update =>
        '''
          UPDATE ${stat.title} SET
            $qty = $qty - COALESCE(OLD.$trnQty, 0) + COALESCE(NEW.$trnQty, 0),
            $invested = $invested - IIF(OLD.$trnAmt > 0, OLD.$trnAmt, 0) + IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0),
            $redeemed = $redeemed - IIF(OLD.$trnAmt < 0, OLD.$trnAmt, 0) + IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0),
            $xirr = NULL -- reset xirr to be recalculated later
          WHERE $accId = NEW.$trnAccId AND $amcId = NEW.$trnAmcId;
        ''',

      TableEventType.delete =>
        '''
          UPDATE ${stat.title} SET
            $numTx = MAX(0, $numTx - 1),
            $qty = $qty - COALESCE(OLD.$trnQty, 0),
            $invested = $invested - IIF(OLD.$trnAmt > 0, OLD.$trnAmt, 0),
            $redeemed = $redeemed - IIF(OLD.$trnAmt < 0, OLD.$trnAmt, 0),
            $xirr = NULL -- reset xirr to be recalculated later
          WHERE $accId = OLD.$trnAccId AND $amcId = OLD.$trnAmcId;
        ''',
    };
  }

  // helper function to get a table out of initialized tables
  T? getTable<T extends TableSchema>() => _tables.firstWhereOrNull((table) => table is T) as T?;

  Future<List<Map<String, dynamic>>> select(
    TableSchema table, {
    List<TableSchema> join = const [],
    List<TableColumnBase>? columns,
    List<TableColumn>? groupBy,
    TableFilter? filter,
    int? limit,
    Map<TableColumn, bool>? orderBy,
  }) async {
    final List<Map<String, dynamic>> data = [];

    // SELECT table1.*, table2.id as table2_id FROM table1 JOIN table2 ON table1.amc_id = table2.id
    final effectiveTableName = StringBuffer(table.title);
    final defaultTableColumns = List<TableColumnBase>.from(table.columns);

    if (join.isNotEmpty && table.foreignKeys.isNotEmpty) {
      for (final j in join) {
        // get foreignKey
        final fkc = table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == j.title);
        if (fkc == null) continue;
        // Write table name
        effectiveTableName.write(' JOIN ${j.title} ');
        effectiveTableName.write('ON ${fkc.fullTitle} = ${j.title}.${fkc.foreignReference!.columnName}');

        // Write default table columns
        final jColumns = j.columns.map<TableColumnBase>((col) {
          return col.alias('${j.type.toString().toCamelCase()}_${col.title}');
        });
        defaultTableColumns.addAll(jColumns);
      }
    }

    final whereClause = filter?.toSql();

    // print query for debugging
    $logger.d('''SELECT ${defaultTableColumns.map((col) => col.fullTitleWithAggregateAndAlias).join(', ')}
       FROM $effectiveTableName
       ${whereClause != null ? 'WHERE ${whereClause.$1}' : ''}
       ${groupBy != null ? 'GROUP BY ${groupBy.map((col) => col.fullTitle).join(', ')}' : ''}
       ${limit != null ? 'LIMIT $limit' : ''}''');

    try {
      final list = await db.query(
        effectiveTableName.toString(),
        columns: (columns ?? defaultTableColumns).map<String>((col) => col.fullTitleWithAggregateAndAlias).toList(),
        where: whereClause?.$1,
        whereArgs: whereClause?.$2,
        limit: limit,
        groupBy: groupBy?.map<String>((col) => col.fullTitle).join(', '),
        orderBy: orderBy?.entries.map<String>((col) => '${col.key.fullTitle} ${col.value ? 'DESC' : 'ASC'}').join(', '),
      );

      if (list.isEmpty) return List<Map<String, dynamic>>.empty();

      for (final el in list) {
        final map = Map<String, dynamic>.from(el);
        if (join.isNotEmpty && table.foreignKeys.isNotEmpty) {
          for (final j in join) {
            final fkc = table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == j.title);
            if (fkc == null) continue;
            map.nest(j.type.toString().toCamelCase());
          }
        }
        data.add(map);
      }
    } on Exception catch (err) {
      $logger.e(err);
      rethrow;
    }
    return data;
  }

  Future<int> insert(TableSchema table, TableDataModel data) async {
    final values = table.fromModel(data);
    for (final pkc in table.primaryKeys) {
      if (pkc.isAutoIncrement) {
        values.remove(pkc.title);
      }
    }
    final r = await db.insert(table.title, values);
    _tableEventController.add(TableEvent(table, TableEventType.insert, data));
    return r;
  }

  Future<int> update(TableSchema table, TableDataModel data) async {
    final values = table.fromModel(data);
    final where = <String>[];
    final whereArgs = <Object>[];
    for (final pkc in table.primaryKeys) {
      where.add('${pkc.fullTitle} = ?');
      whereArgs.add(values.remove(pkc.title));
    }

    final r = await db.update(table.title, values, where: where.join(' AND '), whereArgs: whereArgs);
    _tableEventController.add(TableEvent(table, TableEventType.update, data));
    return r;
  }

  Future<int> delete(TableSchema table, TableDataModel data) async {
    final values = table.fromModel(data);
    final where = <String>[];
    final whereArgs = <Object>[];
    for (final pkc in table.primaryKeys) {
      where.add('${pkc.fullTitle} = ?');
      whereArgs.add(values.remove(pkc.title));
    }
    final r = await db.delete(table.title, where: where.join(' AND '), whereArgs: whereArgs);
    _tableEventController.add(TableEvent(table, TableEventType.delete, data));
    return r;
  }

  Future<void> close() async {
    await _db?.close();
    await _tableEventController.close();
  }
}
