import 'dart:async';
import 'package:invesly/database/table_schema.dart';

import 'user_model.dart';

import 'package:invesly/database/invesly_api.dart';

class UserRepository {
  const UserRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  UserTable get _userTable => _api.userTable;

  /// Stream of UserTable changes
  Stream<TableChangeEvent> get onTableChange => _api.table(_userTable).tableChangeEvent;

  /// Get all users
  Future<List<InveslyUser>> getUsers() async {
    final list = await _api.table(_userTable).select().toList();

    return list.map<InveslyUser>((el) => InveslyUser.fromDb(_userTable.encode(el))).toList();
  }

  /// Add or update user to database
  Future<void> saveUser(UserInDb user, [bool isNew = true]) async {
    if (isNew) {
      await _api.table(_userTable).insert(user);
    } else {
      await _api.table(_userTable).update(user);
    }
  }
}
