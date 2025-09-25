import 'package:invesly/common_libs.dart';

enum TableColumnType {
  integer,
  string,
  real,
  boolean;

  String toSqlType() {
    return switch (this) {
      TableColumnType.integer => 'INTEGER',
      TableColumnType.string => 'TEXT',
      TableColumnType.real => 'REAL',
      TableColumnType.boolean => 'BOOLEAN',
    };
  }
}

// enum TableFilterOperator { equal, notEqual, greaterThan, lessThan, greaterThanOrEqual, lessThanOrEqual, like, inList, between }
enum TableChangeEventType { insertion, updation, deletion }

abstract class TableFilter<T extends Object> {
  const TableFilter();

  (String, List<T>) toSql();
}

class SingleValueTableFilter<T extends Object> implements TableFilter<T> {
  const SingleValueTableFilter(this.column, this.value)
    : assert(T == String || T == num || T == bool, 'Value must be of type String, num or bool');

  final TableColumn column;
  final T value;

  @override
  (String, List<T>) toSql() {
    return ('${column.fullTitle} = ?', [value]);
  }
}

class MultipleValueTableFilter<T extends Object> implements TableFilter<T> {
  MultipleValueTableFilter(this.column, this.values)
    : assert(T == String || T == num || T == bool, 'Value must be of type String, num or bool'),
      assert(values.isNotEmpty, 'Values list must not be empty');

  final TableColumn column;
  final List<T> values;

  @override
  (String, List<T>) toSql() {
    final placeholders = values.map((_) => '?').join(', ');
    return ('${column.fullTitle} IN ($placeholders)', values);
  }
}

class RangeValueTableFilter<T extends Object> implements TableFilter<T> {
  const RangeValueTableFilter(this.column, this.start, this.end)
    : assert(T == String || T == num || T == bool, 'Value must be of type String, num or bool');

  final TableColumn column;
  final T start;
  final T end;

  @override
  (String, List<T>) toSql() {
    return ('${column.fullTitle} BETWEEN ? AND ?', [start, end]);
  }
}

class TableFilterGroup extends TableFilter {
  const TableFilterGroup(this.filters, {this.isAnd = true});

  final List<TableFilter<Object>> filters;
  final bool isAnd;

  @override
  (String, List<Object>) toSql() {
    final sqlParts = <String>[];
    final args = <Object>[];

    for (final filter in filters) {
      final (sql, filterArgs) = filter.toSql();
      sqlParts.add(sql);
      args.addAll(filterArgs);
    }

    final combinedSql = '(${sqlParts.join(isAnd ? ' AND ' : ' OR ')})';
    return (combinedSql, args);
  }
}

class TableQueryBuilder<T extends InveslyDataModel> implements TableFilterBuilder<T> {
  TableQueryBuilder({required Database db, required TableSchema table, List<TableColumnBase>? columns})
    : _db = db,
      _table = table,
      _columns = columns ?? [];

  final Database _db;
  final TableSchema _table;
  final List<TableColumnBase> _columns;

  final List<TableSchema> _joinTables = [];
  // final List<TableFilter> _where = [];
  TableFilter? _where;
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

  TableQueryBuilder<T> join(List<TableSchema> tables) {
    if (tables.isNotEmpty) {
      _joinTables.addAll(tables);
    }
    return this;
  }

  @override
  TableFilterBuilder where(List<TableFilter> filters, {bool isAnd = true}) {
    if (filters.isNotEmpty) {
      //   _where.addAll(filters);
      _where = TableFilterGroup(filters, isAnd: isAnd);
    }
    return this;
  }

  @override
  TableFilterBuilder groupBy(List<TableColumn> columns) {
    if (columns.isNotEmpty) {
      _group.addAll(columns);
    }
    return this;
  }

  @override
  Future<List<Map<String, dynamic>>> toList() async {
    final List<Map<String, dynamic>> data = [];

    // final where = _where.isEmpty ? null : _where.keys.map<String>((key) => '${key.fullTitle} = ?').join(' AND ');
    // final whereArgs = _where.isEmpty ? null : _where.values.toList();

    // final whereMap = _where.isEmpty ? null : _where.map((fv) => fv.toSql());
    final whereMap = _where?.toSql();
    // final where = whereMap?.map<String>((fv) => fv.$1).join(' AND ');
    // final whereArgs = whereMap?.map((fv) => fv.$2).expand((el) => el).toList();

    final groupBy = _group.isEmpty ? null : _group.map<String>((col) => col.fullTitle).join(', ');

    try {
      final list = await _db.query(
        effectiveTableName,
        columns: effectiveTableColumns,
        where: whereMap?.$1,
        whereArgs: whereMap?.$2,
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

abstract class TableFilterBuilder<T extends InveslyDataModel> {
  TableFilterBuilder where(List<TableFilter> filters);

  TableFilterBuilder groupBy(List<TableColumn> columns);

  Future<List<Map<String, dynamic>>> toList();

  // InveslyApiFilterBuilder orderBy(String column) => InveslyApiFilterBuilder();

  // InveslyApiFilterBuilder limit(int limit) => InveslyApiFilterBuilder();
}

abstract class InveslyDataModel extends Equatable {
  const InveslyDataModel({required this.id});

  final String id;

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id];
}

abstract class TableSchema<T extends InveslyDataModel> extends Equatable {
  final String name;

  const TableSchema(this.name);

  TableColumn<String> get idColumn => TableColumn('id', name, isPrimary: true);

  /// Get all columns
  Set<TableColumn> get columns => {idColumn};

  /// Get primary keys
  Set<TableColumn> get primaryKeys => columns.where((col) => col.isPrimary).toSet();

  /// Get foreign keys
  Set<TableColumn> get foreignKeys => columns.where((col) => col.foreignReference != null).toSet();

  Type get type => T;

  /// Convert the data model to a map acceptable by the table
  Map<String, dynamic> decode(T data);

  /// Convert the map from a table to a data model
  T encode(Map<String, dynamic> map);

  @override
  List<Object?> get props => [name];

  /// Create table SQL statement
  String createTable() {
    final columnDefs = columns
        .map<String>((col) {
          final buffer = StringBuffer('${col.title} ${col.type.toSqlType()}');

          if (col.isPrimary) {
            buffer.write(' PRIMARY KEY');
          }
          if (col.isUnique) {
            buffer.write(' UNIQUE');
          }
          if (!col.isNullable) {
            buffer.write(' NOT NULL');
          }
          if (col.defaultValue != null) {
            buffer.write(' DEFAULT ${col.defaultValue}');
          }
          if (col.foreignReference != null) {
            buffer.write(' REFERENCES ${col.foreignReference!.tableName}(${col.foreignReference!.columnName})');
          }

          return buffer.toString();
        })
        .join(', ');

    return 'CREATE TABLE IF NOT EXISTS $name ($columnDefs);';
  }
}

class TableColumnBase extends Equatable {
  const TableColumnBase(this.title, this.tableName, [this.aggregateFunc, this.aliasTitle]);

  final String title;
  final String tableName;
  final String? aggregateFunc;
  final String? aliasTitle;

  /// Effective title of the column in the SQL query
  String get fullTitle {
    final buffer = StringBuffer();

    if (aggregateFunc != null) {
      buffer.write('$aggregateFunc(');
    }

    buffer.write('$tableName.$title');

    if (aggregateFunc != null) {
      buffer.write(')');
    }

    if (aliasTitle != null) {
      buffer.write(' AS $aliasTitle');
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [title, tableName, aggregateFunc, aliasTitle];
}

class TableColumn<T extends Object> extends TableColumnBase {
  const TableColumn(
    super.title,
    super.tableName, {
    this.type = TableColumnType.string,
    this.defaultValue,
    this.isPrimary = false,
    this.isNullable = false,
    this.isUnique = false,
    this.foreignReference,
  });

  final TableColumnType type;
  final String? defaultValue;
  final bool isPrimary;
  final bool isNullable;
  final bool isUnique;
  final ForeignReference? foreignReference;

  TableColumnBase alias(String aliasTitle) => TableColumnBase(title, tableName, null, aliasTitle);

  TableColumnBase count([String? alias]) => TableColumnBase(title, tableName, 'COUNT', alias);

  TableColumnBase sum([String? alias]) => TableColumnBase(title, tableName, 'SUM', alias);

  TableColumnBase avg([String? alias]) => TableColumnBase(title, tableName, 'AVG', alias);

  TableColumnBase min([String? alias]) => TableColumnBase(title, tableName, 'MIN', alias);

  TableColumnBase max([String? alias]) => TableColumnBase(title, tableName, 'MAX', alias);

  @override
  List<Object?> get props => [fullTitle, type, defaultValue, isPrimary, isNullable, isUnique, foreignReference];
}

class ForeignReference extends Equatable {
  final String tableName;
  final String columnName;

  const ForeignReference(this.tableName, this.columnName);

  @override
  List<Object?> get props => [tableName, columnName];
}

class TableChangeEvent {
  final TableSchema table;
  final TableChangeEventType type;

  const TableChangeEvent(this.table, this.type);
}
