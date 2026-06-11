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
    );

    // ?? Close database at the end ??
    _tables.addAll([_accountTable, _amcTable, _trnTable, _statTable]);
  }

  // Build trigger operation SQL dynamically using schema column names
  String _buildTriggerOperation(TableEventType eventType) {
    final stat = _statTable;
    final accId = stat.accountIdColumn.title;
    final amcId = stat.amcIdColumn.title;
    final numTx = stat.numTransactionsColumn.title;
    final qty = stat.totalQuantityColumn.title;
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
          INSERT OR IGNORE INTO ${stat.tableName} ($accId, $amcId, $numTx, $qty, $invested, $redeemed)
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
          UPDATE ${stat.tableName} SET
            $qty = $qty - COALESCE(OLD.$trnQty, 0) + COALESCE(NEW.$trnQty, 0),
            $invested = $invested - IIF(OLD.$trnAmt > 0, OLD.$trnAmt, 0) + IIF(NEW.$trnAmt > 0, NEW.$trnAmt, 0),
            $redeemed = $redeemed - IIF(OLD.$trnAmt < 0, OLD.$trnAmt, 0) + IIF(NEW.$trnAmt < 0, NEW.$trnAmt, 0),
            $xirr = NULL -- reset xirr to be recalculated later
          WHERE $accId = NEW.$trnAccId AND $amcId = NEW.$trnAmcId;
        ''',

      TableEventType.delete =>
        '''
          UPDATE ${stat.tableName} SET
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

  TableQueryBuilder select(TableSchema table, {List<TableColumnBase>? columns, int? limit}) {
    late final TableQueryBuilder builder;
    builder = TableQueryBuilder(table: table, columns: columns, executor: (limit) => _executeTableQuery(limit));
    final List<Map<String, dynamic>> data = [];
    final whereSql = builder.whereSql;
    final whereArgs = builder.whereArgs;
    final groupBy = builder.groupBySql;
    debugPrint(
      'Query: SELECT ${builder.effectiveTableColumns.join(', ')} FROM ${builder.effectiveTableName}'
      '${whereSql != null ? ' WHERE $whereSql: $whereArgs' : ''}'
      '${groupBy != null ? ' GROUP BY $groupBy' : ''}'
      '${limit != null ? ' LIMIT $limit' : ''}',
    );

    try {
      final list = db.query(
        builder.effectiveTableName,
        columns: builder.effectiveTableColumns,
        where: whereSql,
        whereArgs: whereArgs,
        limit: limit,
        groupBy: groupBy,
      );

      // Move rest of the code to table_schema
      if (list.isEmpty) return List<Map<String, dynamic>>.empty();

      for (final el in list) {
        final map = Map<String, dynamic>.from(el);
        if (builder.joinTables.isNotEmpty && builder.table.foreignKeys.isNotEmpty) {
          for (final joinTable in builder.joinTables) {
            final fkc = builder.table.foreignKeys.firstWhereOrNull(
              (c) => c.foreignReference!.tableName == joinTable.tableName,
            );

            if (fkc == null) continue;

            map.nest(joinTable.type.toString().toCamelCase());
          }
        }

        data.add(map);
      }
    } on Exception catch (err) {
      $logger.e(err);
    }

    return builder;
  }

  Future<int> insert(TableSchema table, TableDataModel data) async {
    final r = await db.insert(table.tableName, table.fromModel(data));
    _tableEventController.add(TableEvent(table, TableEventType.insert, data));
    return r;
  }

  Future<int> update(TableSchema table, TableDataModel data) async {
    final r = await db.update(
      table.tableName,
      table.fromModel(data),
      where: '${table.idColumn.fullTitle} = ?',
      whereArgs: [data.id],
    );
    _tableEventController.add(TableEvent(table, TableEventType.update, data));
    return r;
  }

  Future<int> delete(TableSchema table, TableDataModel data) async {
    final r = await Future.delayed(2.seconds, () => 1); // TODO: implement
    _tableEventController.add(TableEvent(table, TableEventType.delete, data));
    return r;
  }

  Future<void> close() async {
    await _db?.close();
    await _tableEventController.close();
  }
}
