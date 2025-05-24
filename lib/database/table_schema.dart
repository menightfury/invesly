import 'package:invesly/common_libs.dart';

enum TableColumnType { integer, string, real, boolean }

enum TableChangeEventType { insertion, updation, deletion }

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
}

class TableColumnBase extends Equatable {
  const TableColumnBase(this.name, this.tableName, [this.aggregateFunc, this.aliasName]);

  final String name;
  final String tableName;
  final String? aggregateFunc;
  final String? aliasName;

  /// Effective title of the column in the SQL query
  String get title {
    final buffer = StringBuffer();

    if (aggregateFunc != null) {
      buffer.write('$aggregateFunc(');
    }

    buffer.write('$tableName.$name');

    if (aggregateFunc != null) {
      buffer.write(')');
    }

    if (aliasName != null) {
      buffer.write(' AS $aliasName');
    }

    return buffer.toString();
  }

  @override
  List<Object?> get props => [name, tableName, aggregateFunc, aliasName];
}

class TableColumn<T extends Object> extends TableColumnBase {
  const TableColumn(
    super.name,
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

  TableColumnBase alias(String title) => TableColumnBase(name, tableName, null, title);

  TableColumnBase count([String? alias]) => TableColumnBase(name, tableName, 'COUNT', alias);

  TableColumnBase sum([String? alias]) => TableColumnBase(name, tableName, 'SUM', alias);

  TableColumnBase avg([String? alias]) => TableColumnBase(name, tableName, 'AVG', alias);

  TableColumnBase min([String? alias]) => TableColumnBase(name, tableName, 'MIN', alias);

  TableColumnBase max([String? alias]) => TableColumnBase(name, tableName, 'MAX', alias);

  @override
  List<Object?> get props => [title, type, defaultValue, isPrimary, isNullable, isUnique, foreignReference];
}

class ForeignReference extends Equatable {
  final String tableName;
  final String columnName;

  const ForeignReference(this.tableName, this.columnName);

  @override
  List<Object?> get props => [tableName, columnName];
}

class TableChangeEvent {
  final TableSchema schema;
  final TableChangeEventType type;

  const TableChangeEvent(this.schema, this.type);
}
