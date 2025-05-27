import 'dart:async';
import 'package:invesly/database/data_access_object.dart';

import 'user_model.dart';

import 'package:invesly/database/invesly_api.dart';

class UserRepository extends DataAccessObject<UserInDb> {
  UserRepository(InveslyApi api) : super(db: api.db, table: api.userTable);

  /// Get all users
  Future<List<InveslyUser>> getUsers() async {
    final list = await select().toList();

    return list.map<InveslyUser>((el) => InveslyUser.fromDb(table.encode(el))).toList();
  }

  /// Add or update user to database
  Future<void> saveUser(UserInDb user, [bool isNew = true]) async {
    if (isNew) {
      await insert(user);
    } else {
      await update(user);
    }
  }
}
