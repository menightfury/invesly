// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:csv/csv.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

// ~~~ Query Builder ~~~
class DaoQueryBuilder<T extends InveslyDataModel> implements DaoFilterBuilder<T> {
  DaoQueryBuilder({required Database db, required TableSchema table, List<TableColumnBase>? columns})
    : _db = db,
      _table = table,
      _columns = columns ?? [];

  final Database _db;
  final TableSchema _table;
  final List<TableColumnBase> _columns;

  final List<TableSchema> _joinTables = [];
  final Map<TableColumn, dynamic> _where = {};
  final List<TableColumnBase> _group = [];

  String get effectiveTableName {
    // SELECT table1.*, table2.id as table2_id FROM table1 JOIN table2 ON table1.amc_id = table2.id
    final tableName = StringBuffer(_table.name);
    if (_joinTables.isNotEmpty && _table.foreignKeys.isNotEmpty) {
      for (final joinTable in _joinTables) {
        // get foreignKey
        final fkc = _table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == joinTable.name);

        if (fkc == null) continue;

        tableName.write(
          ' JOIN ${joinTable.name} ON ${fkc.fullTitle} = ${joinTable.name}.${fkc.foreignReference!.columnName}',
        );
      }
    }
    return tableName.toString();
  }

  List<String> get effectiveTableColumns {
    if (_columns.isEmpty) {
      // SELECT table1.*, table2.id as table2_id FROM table1 JOIN table2 ON table1.amc_id = table2.id
      _columns.addAll(_table.columns);
      if (_joinTables.isNotEmpty && _table.foreignKeys.isNotEmpty) {
        for (final joinTable in _joinTables) {
          // get foreignKey
          final fkc = _table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == joinTable.name);

          if (fkc == null) continue;

          final joinTableColumns = joinTable.columns.map<TableColumnBase>((col) {
            return col.alias('${joinTable.type.toString().toCamelCase()}_${col.title}');
          });

          _columns.addAll(joinTableColumns);
        }
      }
    }

    return _columns.map<String>((col) => col.fullTitle).toList();
  }

  DaoQueryBuilder<T> join(List<TableSchema> tables) {
    if (tables.isNotEmpty) {
      _joinTables.addAll(tables);
    }
    return this;
  }

  @override
  DaoFilterBuilder where(Map<TableColumn, dynamic> condition) {
    if (condition.isNotEmpty) {
      _where.addAll(condition);
    }
    return this;
  }

  @override
  DaoFilterBuilder groupBy(List<TableColumn> columns) {
    if (columns.isNotEmpty) {
      _group.addAll(columns);
    }
    return this;
  }

  @override
  Future<List<Map<String, dynamic>>> toList() async {
    final List<Map<String, dynamic>> data = [];

    final where = _where.isEmpty ? null : _where.keys.map<String>((key) => '${key.fullTitle} = ?').join(' AND ');
    final whereArgs = _where.isEmpty ? null : _where.values.toList();

    final groupBy = _group.isEmpty ? null : _group.map<String>((col) => col.fullTitle).join(', ');

    try {
      final list = await _db.query(
        effectiveTableName,
        columns: effectiveTableColumns,
        where: where,
        whereArgs: whereArgs,
        // orderBy: orderBy,
        // limit: limit,
        groupBy: groupBy,
      );
      if (list.isEmpty) return List<Map<String, dynamic>>.empty();

      for (final el in list) {
        final map = Map<String, dynamic>.from(el);
        if (_joinTables.isNotEmpty && _table.foreignKeys.isNotEmpty) {
          for (final joinTable in _joinTables) {
            final fkc = _table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == joinTable.name);

            if (fkc == null) continue;

            map.nest(joinTable.type.toString().toCamelCase());
          }
        }

        data.add(map);
      }
    } on Exception catch (err) {
      $logger.e(err);
    }
    return data;
  }
}

// ~~~ Filter Builder ~~~
abstract class DaoFilterBuilder<T extends InveslyDataModel> {
  DaoFilterBuilder where(Map<TableColumn, dynamic> condition);

  DaoFilterBuilder groupBy(List<TableColumn> columns);

  Future<List<Map<String, dynamic>>> toList();

  // InveslyApiFilterBuilder orderBy(String column) => InveslyApiFilterBuilder();

  // InveslyApiFilterBuilder limit(int limit) => InveslyApiFilterBuilder();
}

// ~~~ Data Access Object ~~~
abstract class DataAccessObject<T extends InveslyDataModel> {
  DataAccessObject({required Database db, required this.table})
    : _db = db,
      _tableChangeEventController = StreamController<TableChangeEvent>.broadcast();

  final Database _db;
  final TableSchema<T> table;
  final StreamController<TableChangeEvent> _tableChangeEventController;

  // Stream of TableChangeEvent
  Stream<TableChangeEvent> get onTableChange => _tableChangeEventController.stream;

  Future<int> insert(T data) async {
    final r = await _db.insert(table.name, table.decode(data));
    _tableChangeEventController.add(TableChangeEvent(table, TableChangeEventType.insertion));
    return r;
  }

  Future<int> update(T data) async {
    final r = await _db.update(
      table.name,
      table.decode(data),
      where: '${table.idColumn.fullTitle} = ?',
      whereArgs: [data.id],
    );
    _tableChangeEventController.add(TableChangeEvent(table, TableChangeEventType.updation));
    return r;
  }

  Future<int> delete(T data) async {
    final r = await Future.delayed(2.seconds, () => 1); // TODO: implement
    _tableChangeEventController.add(TableChangeEvent(table, TableChangeEventType.deletion));
    return r;
  }

  DaoQueryBuilder select([List<TableColumnBase>? columns]) {
    return DaoQueryBuilder(db: _db, table: table, columns: columns);
  }

  Future<String> tableDataToCsv([String separator = ',']) async {
    final csvHeader = table.columns.map((col) => col.title.toCamelCase()).toList();
    final data = await select().toList();

    final csvData = data.map((d) => d.values.toList()).toList();

    return const ListToCsvConverter().convert([csvHeader, ...csvData], fieldDelimiter: separator);
  }
}
