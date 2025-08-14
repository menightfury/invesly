import 'dart:async';
import 'package:invesly/database/data_access_object.dart';

import 'account_model.dart';

import 'package:invesly/database/invesly_api.dart';

class AccountRepository extends DataAccessObject<AccountInDb> {
  AccountRepository(InveslyApi api) : super(db: api.db, table: api.accountTable);

  /// Get all accounts
  Future<List<InveslyAccount>> getAccounts() async {
    final list = await select().toList();

    return list.map<InveslyAccount>((el) => InveslyAccount.fromDb(table.encode(el))).toList();
  }

  /// Add or update account to database
  Future<void> saveAccount(AccountInDb account, [bool isNew = true]) async {
    if (isNew) {
      await insert(account);
    } else {
      await update(account);
    }
  }
}
