import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:invesly/database/invesly_api.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('migrates an older accounts table to the new schema', () async {
    final tempDir = await Directory.systemTemp.createTemp('invesly_migration_test');
    addTearDown(() async {
      await tempDir.delete(recursive: true);
    });

    final dbPath = p.join(tempDir.path, 'invesly.db');

    final initialDb = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          )
        ''');
      },
    );

    await initialDb.insert('accounts', {'name': 'Checking', 'description': 'old row'});
    await initialDb.close();

    final api = InveslyApi(tempDir);
    await api.initializeDatabase();

    final migratedRows = await api.db.query(
      'accounts',
      columns: ['id', 'name', 'description', 'icon', 'color'],
      where: 'id = ?',
      whereArgs: [1],
    );

    expect(migratedRows, isNotEmpty);
    expect(migratedRows.single['name'], 'Checking');
    expect(migratedRows.single['description'], 'old row');
    expect(migratedRows.single['icon'], isNull);
    expect(migratedRows.single['color'], isNull);

    await api.close();
  });
}
