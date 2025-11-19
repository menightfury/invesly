import 'dart:async';
// import 'package:invesly/database/data_access_object.dart';

import 'package:invesly/database/table_schema.dart';

import 'account_model.dart';

import 'package:invesly/database/invesly_api.dart';

// class AccountRepository extends DataAccessObject<InveslyAccount> {
class AccountRepository {
  // AccountRepository(InveslyApi api) : super(db: api.db, table: api.accountTable);
  AccountRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  AccountTable get _accountTable => _api.accountTable;

  Stream<TableChangeEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.table == _accountTable);
  }

  /// Get all accounts
  Future<List<InveslyAccount>> getAccounts() async {
    final list = await _api.select(_accountTable).toList();

    return list.map<InveslyAccount>((el) => InveslyAccount.fromDb(_accountTable.fromMap(el))).toList();
  }

  /// Get account by id
  Future<InveslyAccount?> getAccountById(String id) async {
    final list = await _api.select(_accountTable).where([
      SingleValueTableFilter<String>(_accountTable.idColumn, id),
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
    final list = await _api.select(_accountTable).where([
      SingleValueTableFilter<String>(_accountTable.idColumn, value),
      SingleValueTableFilter<String>(_accountTable.nameColumn, value),
    ], isAnd: false).toList();

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
