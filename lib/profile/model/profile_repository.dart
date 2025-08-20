import 'dart:async';
// import 'package:invesly/database/data_access_object.dart';

import 'package:invesly/database/table_schema.dart';

import 'profile_model.dart';

import 'package:invesly/database/invesly_api.dart';

// class AccountRepository extends DataAccessObject<InveslyAccount> {
class ProfileRepository {
  // AccountRepository(InveslyApi api) : super(db: api.db, table: api.accountTable);
  ProfileRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  ProfileTable get _accountTable => _api.profileTable;

  Stream<TableChangeEvent> get onDataChanged {
    return _api.onTableChange.where((event) => event.table == _accountTable);
  }

  /// Get all accounts
  Future<List<InveslyProfile>> getAccounts() async {
    final list = await _api.select(_accountTable).toList();

    return list.map<InveslyProfile>((el) => InveslyProfile.fromDb(_accountTable.encode(el))).toList();
  }

  /// Add or update account to database
  Future<void> saveAccount(ProfileInDb account, [bool isNew = true]) async {
    if (isNew) {
      await _api.insert(_accountTable, account);
    } else {
      await _api.update(_accountTable, account);
    }
  }
}
