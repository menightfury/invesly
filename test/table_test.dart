// ignore_for_file: avoid_print

import 'package:invesly/stat/model/stat_model.dart';
import 'package:invesly/database/table_schema.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

void main() {
  final trn = TransactionInDb(id: 2, accountId: 1, amcId: 'amc', date: 1780662307000);
  final trnTable = TransactionTable();
  final statTable = StatTable();

  print(statTable.createTable());
  print(trnTable.createTable());
  print(update(trnTable, trn));
  print(delete(trnTable, trn));
}

String update(TableSchema table, TableDataModel data) {
  final values = table.fromModel(data);
  final where = <String>[];
  final whereArgs = <Object>[];
  for (final pkc in table.primaryKeys) {
    where.add('${pkc.fullTitle} = ?');
    whereArgs.add(values.remove(pkc.title));
  }

  return '''
      UPDATE ${table.tableName}
      SET $values
      WHERE ${where.join(' AND ')};
      -- with args: $whereArgs
    ''';
}

String delete(TableSchema table, TableDataModel data) {
  final values = table.fromModel(data);
  final where = <String>[];
  final whereArgs = <Object>[];
  for (final pkc in table.primaryKeys) {
    where.add('${pkc.fullTitle} = ?');
    whereArgs.add(values.remove(pkc.title));
  }

  return '''
      DELETE FROM ${table.tableName}
      WHERE ${where.join(' AND ')};
      -- with args: $whereArgs
    ''';
}
