import 'dart:async';

import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/database/table_schema.dart';

import 'account_model.dart';

class AccountRepository {
  // singleton api instance
  static AccountRepository? _instance;
  static AccountRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory AccountRepository.initialize(InveslyApi api) {
    _instance ??= AccountRepository._(api);
    return _instance!;
  }
  AccountRepository._(this._api);

  final InveslyApi _api;

  AccountTable get _accountTable => _api.accountTable;

  Stream<TableEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.tables.contains(_accountTable));
  }

  /// Get all accounts
  Future<List<InveslyAccount>> getAccounts() async {
    final list = await _api.select(_accountTable).toList();

    return list.map<InveslyAccount>((el) => InveslyAccount.fromDb(_accountTable.fromMap(el))).toList();
  }

  /// Get account by id
  Future<InveslyAccount?> getAccountById(int id) async {
    final list = await _api.select(_accountTable).where([
      SingleValueTableFilter<int>(_accountTable.idColumn, id),
    ]).toList();

    if (list.isEmpty) return null;

    return InveslyAccount.fromDb(_accountTable.fromMap(list.first));
  }

  /// Get account by name
  Future<InveslyAccount?> getAccountByName(String name) async {
    final list = await _api.select(_accountTable).where([
      SingleValueTableFilter<String>(_accountTable.nameColumn, name),
    ]).toList();

    if (list.isEmpty) return null;

    return InveslyAccount.fromDb(_accountTable.fromMap(list.first));
  }

  /// Get account by id or name
  Future<InveslyAccount?> getAccount(String value) async {
    final parsedId = int.tryParse(value);
    final filters = <TableFilter>[
      SingleValueTableFilter<String>(_accountTable.nameColumn, value),
    ];
    if (parsedId != null) {
      filters.add(SingleValueTableFilter<int>(_accountTable.idColumn, parsedId));
    }
    final list = await _api.select(_accountTable).where(filters, isAnd: false).toList();

    if (list.isEmpty) return null;

    return InveslyAccount.fromDb(_accountTable.fromMap(list.first));
  }

  /// Add or update account to database
  Future<void> saveAccount(AccountInDb account, [bool isNew = true]) async {
    if (isNew) {
      await _api.insert(_accountTable, account);
    } else {
      await _api.update(_accountTable, account);
    }
  }
}
