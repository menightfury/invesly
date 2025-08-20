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
