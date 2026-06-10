import 'package:invesly/common_libs.dart';

// ~ Table schema
abstract class TableDataModel<T> extends Equatable {
  const TableDataModel({required this.id});

  final T id;

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [id];
}

abstract class TableSchema<D extends TableDataModel> extends Equatable {
  final String tableName;

  const TableSchema(this.tableName);

  TableColumn get idColumn;

  /// Get all columns
  Set<TableColumn> get columns;

  /// Get primary keys
  Set<TableColumn> get primaryKeys => columns.where((col) => col.isPrimary).toSet();

  /// Get foreign keys
  Set<TableColumn> get foreignKeys => columns.where((col) => col.foreignReference != null).toSet();

  Type get type => D;

  /// Convert the data model to a map acceptable by the table
  Map<String, dynamic> fromModel(D data);

  /// Convert the map from a table to a data model
  D fromMap(Map<String, dynamic> map);

  @override
  List<Object?> get props => [tableName];

  /// Create table SQL statement
  String createTable() {
    final columnDefs = columns
        .map<String>((col) {
          final buffer = StringBuffer('${col.title} ${col.sqlType}');

          if (col.isPrimary) {
            buffer.write(' PRIMARY KEY');
            if (col.isAutoIncrement && col.runtimeType == int) {
              buffer.write(' AUTOINCREMENT');
            }
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

    return 'CREATE TABLE IF NOT EXISTS $tableName ($columnDefs);';
  }

  // Create trigger for table
  String createTrigger({required TableEventType eventType, required String operation}) {
    return '''
      CREATE TRIGGER IF NOT EXISTS ${tableName}_${eventType.name}_trigger 
      AFTER ${eventType.sql} ON $tableName
      FOR EACH ROW
      BEGIN
        $operation
      END;
    ''';
  }
}

class TableColumnBase extends Equatable {
  const TableColumnBase(this.title, this.tableName, [this.aggregateMethodName, this.aliasTitle, this.aggregateFilter]);

  final String title;
  final String tableName;
  final String? aggregateMethodName;
  final String? aliasTitle;
  final TableFilter? aggregateFilter;

  /// Full title of the column
  String get fullTitle => '$tableName.$title';

  /// Effective title of the column in the SQL query
  String get _fullTitleWithAggregateAndAlias {
    final buffer = StringBuffer();

    if (aggregateMethodName != null) {
      buffer.write('$aggregateMethodName(');

      if (aggregateFilter != null) {
        final (filterSql, filterArgs) = aggregateFilter!.toSql();
        // Inline the filter arguments into the SQL string, replacing `?` placeholders
        // with the actual values. This is necessary because sqflite's `query` method
        // only supports parameterized args in the WHERE clause, not in column expressions.
        var inlineSql = filterSql;
        for (final arg in filterArgs) {
          if (arg is String) {
            inlineSql = inlineSql.replaceFirst('?', "'${arg.replaceAll("'", "''")}'");
          } else {
            inlineSql = inlineSql.replaceFirst('?', '$arg');
          }
        }
        buffer.write('CASE WHEN $inlineSql THEN ');
      }
    }

    buffer.write(fullTitle);

    if (aggregateMethodName != null) {
      if (aggregateFilter != null) {
        buffer.write(' ELSE 0 END');
      }
      buffer.write(')');
    }

    if (aliasTitle != null) {
      buffer.write(' AS $aliasTitle');
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [title, tableName, aggregateMethodName, aliasTitle, aggregateFilter];
}

class TableColumn<T extends Object> extends TableColumnBase {
  const TableColumn(
    super.title,
    super.tableName, {
    this.defaultValue,
    this.isPrimary = false,
    this.isNullable = false,
    this.isUnique = false,
    this.isAutoIncrement = false,
    this.foreignReference,
  }) : assert(
         T == String || T == num || T == int || T == double || T == bool,
         'Type must be String, num, int, double or bool',
       ),
       assert(
         (isPrimary && T == int && isAutoIncrement) ||
             (!isPrimary && !isAutoIncrement) ||
             (isPrimary && !isAutoIncrement),
         'Only integer primary keys can be auto-incremented, and auto-increment can only be applied to primary keys.',
       );

  final T? defaultValue;
  final bool isPrimary;
  final bool isNullable;
  final bool isUnique;
  final bool isAutoIncrement;
  final ForeignReference? foreignReference;

  String get sqlType {
    if (T == int) return 'INTEGER';
    if (T == double || T == num) return 'REAL';
    if (T == bool) return 'BOOLEAN';
    return 'TEXT';
  }

  TableColumnBase alias(String aliasTitle) => TableColumnBase(title, tableName, null, aliasTitle);

  TableColumnBase count([String? alias, TableFilter? filter]) =>
      TableColumnBase(title, tableName, 'COUNT', alias, filter);

  TableColumnBase sum([String? alias, TableFilter? filter]) => TableColumnBase(title, tableName, 'SUM', alias, filter);

  TableColumnBase avg([String? alias, TableFilter? filter]) => TableColumnBase(title, tableName, 'AVG', alias, filter);

  TableColumnBase min([String? alias, TableFilter? filter]) => TableColumnBase(title, tableName, 'MIN', alias, filter);

  TableColumnBase max([String? alias, TableFilter? filter]) => TableColumnBase(title, tableName, 'MAX', alias, filter);

  @override
  List<Object?> get props => [
    fullTitle,
    defaultValue,
    isPrimary,
    isNullable,
    isUnique,
    isAutoIncrement,
    foreignReference,
  ];
}

class ForeignReference extends Equatable {
  final String tableName;
  final String columnName;

  const ForeignReference(this.tableName, this.columnName);

  @override
  List<Object?> get props => [tableName, columnName];
}

enum TableEventType {
  insert,
  update,
  delete;

  String get sql {
    return switch (this) {
      insert => 'INSERT',
      update => 'UPDATE',
      delete => 'DELETE',
    };
  }
}

class TableEvent {
  final TableSchema table;
  final TableEventType type;
  final TableDataModel? data;

  const TableEvent(this.table, this.type, [this.data]);
}

// ~ Table filter
abstract class TableFilter {
  const TableFilter();

  /// Returns the SQL query fragment (i.e. \$1) and its arguments (i.e \$2).
  ///
  /// The returned fragment can be used in SQL queries (e.g., WHERE clause).
  /// The returned arguments are the values to be substituted for the placeholders (?) in the SQL fragment.
  ///
  /// Example:
  /// ```dart
  /// final filter = SingleValueTableFilter(TableColumn('age'), 25);
  /// final (sql, args) = filter.toSql();
  /// // sql = "age = ?"
  /// // args = [25]
  /// ```
  (String, List<Object>) toSql();
}

enum FilterOperator {
  equal,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  like;

  @override
  String toString() {
    return switch (this) {
      equal => '=',
      greaterThan => '>',
      lessThan => '<',
      greaterThanOrEqual => '>=',
      lessThanOrEqual => '<=',
      like => 'LIKE',
    };
  }
}

class SingleValueTableFilter<T extends Object> implements TableFilter {
  const SingleValueTableFilter(this.column, this.value, {this.operator = FilterOperator.equal, this.negate = false})
    : assert(
        T == String || T == num || T == int || T == double || T == bool,
        'Value must be of type String, num or bool',
      );

  final TableColumn column;
  final T value;
  final FilterOperator operator;
  final bool negate;

  @override
  (String, List<Object>) toSql() {
    final buffer = StringBuffer();
    if (negate) {
      buffer.write('NOT ');
    }
    buffer.write('${column.fullTitle} $operator ?');
    final arg = value is String && operator == FilterOperator.like ? '%$value%' : value;
    return (buffer.toString(), [arg]);
  }
}

class MultipleValueTableFilter<T extends Object> implements TableFilter {
  MultipleValueTableFilter(this.column, this.values, [this.negate = false])
    : assert(
        T == String || T == num || T == int || T == double || T == bool,
        'Value must be of type String, num or bool',
      ),
      assert(values.isNotEmpty, 'Values list must not be empty');

  final TableColumn column;
  final List<T> values;
  final bool negate;

  @override
  (String, List<T>) toSql() {
    final buffer = StringBuffer();
    if (negate) {
      buffer.write('NOT ');
    }
    buffer.write('${column.fullTitle} IN (');
    buffer.writeAll(Iterable.generate(values.length, (_) => '?'), ', ');
    buffer.write(')');
    return (buffer.toString(), values);
  }
}

class RangeValueTableFilter implements TableFilter {
  const RangeValueTableFilter(this.column, this.start, this.end, [this.negate = false]);

  final TableColumn column;
  final num start;
  final num end;
  final bool negate;

  @override
  (String, List<num>) toSql() {
    final buffer = StringBuffer();
    if (negate) {
      buffer.write('NOT ');
    }
    buffer.write('${column.fullTitle} BETWEEN ? AND ?');
    return (buffer.toString(), [start, end]);
  }
}

class TableFilterGroup extends TableFilter {
  const TableFilterGroup(this.filters, {this.isAnd = true});

  final List<TableFilter> filters;
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

// ~ Table query builder
abstract class TableFilterBuilder<T extends TableDataModel> {
  TableFilterBuilder where(List<TableFilter> filters);

  TableFilterBuilder groupBy(List<TableColumn> columns);

  Future<List<Map<String, dynamic>>> toList({int? limit});

  // InveslyApiFilterBuilder orderBy(String column) => InveslyApiFilterBuilder();
}

class TableQueryBuilder<T extends TableDataModel> implements TableFilterBuilder<T> {
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
    final buffer = StringBuffer(_table.tableName);
    if (_joinTables.isNotEmpty && _table.foreignKeys.isNotEmpty) {
      for (final joinTable in _joinTables) {
        // get foreignKey
        final fkc = _table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == joinTable.tableName);

        if (fkc == null) continue;

        buffer.write(' JOIN ${joinTable.tableName} ');
        buffer.write('ON ${fkc.fullTitle} = ${joinTable.tableName}.${fkc.foreignReference!.columnName}');
      }
    }
    return buffer.toString();
  }

  List<String> get effectiveTableColumns {
    if (_columns.isEmpty) {
      // SELECT table1.*, table2.id as table2_id FROM table1 JOIN table2 ON table1.amc_id = table2.id
      _columns.addAll(_table.columns);
      if (_joinTables.isNotEmpty && _table.foreignKeys.isNotEmpty) {
        for (final joinTable in _joinTables) {
          // get foreignKey
          final fkc = _table.foreignKeys.firstWhereOrNull((c) => c.foreignReference!.tableName == joinTable.tableName);

          if (fkc == null) continue;

          final joinTableColumns = joinTable.columns.map<TableColumnBase>((col) {
            return col.alias('${joinTable.type.toString().toCamelCase()}_${col.title}');
          });

          _columns.addAll(joinTableColumns);
        }
      }
    }

    return _columns.map<String>((col) => col._fullTitleWithAggregateAndAlias).toList();
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
  Future<List<Map<String, dynamic>>> toList({int? limit}) async {
    final List<Map<String, dynamic>> data = [];
    final whereSql = _where?.toSql();
    final groupBy = _group.isEmpty ? null : _group.map<String>((col) => col.fullTitle).join(', ');
    debugPrint(
      'Query: SELECT ${effectiveTableColumns.join(', ')} FROM $effectiveTableName'
      '${whereSql != null ? ' WHERE ${whereSql.$1}: ${whereSql.$2}' : ''}'
      '${groupBy != null ? ' GROUP BY $groupBy' : ''}'
      '${limit != null ? ' LIMIT $limit' : ''}',
    );

    try {
      final list = await _db.query(
        effectiveTableName,
        columns: effectiveTableColumns,
        where: whereSql?.$1,
        whereArgs: whereSql?.$2,
        // orderBy: orderBy,
        limit: limit,
        groupBy: groupBy,
      );
      if (list.isEmpty) return List<Map<String, dynamic>>.empty();

      for (final el in list) {
        final map = Map<String, dynamic>.from(el);
        if (_joinTables.isNotEmpty && _table.foreignKeys.isNotEmpty) {
          for (final joinTable in _joinTables) {
            final fkc = _table.foreignKeys.firstWhereOrNull(
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
    return data;
  }
}
