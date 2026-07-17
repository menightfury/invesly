import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invesly/accounts/model/account_model.dart';

void main() {
  group('Account model', () {
    test('round-trips icon and color fields through the database schema', () {
      final account = AccountInDb(
        id: 1,
        name: 'Test Account',
        iconName: InveslyAccountIcon.wallet.name,
        colorValue: Colors.green.toARGB32(),
        description: 'Primary account',
      );

      final table = AccountTable();
      final map = table.fromModel(account);
      final restored = table.fromMap({...map, table.idColumn.title: account.id});

      expect(restored.id, account.id);
      expect(restored.name, account.name);
      expect(restored.iconName, account.iconName);
      expect(restored.colorValue, account.colorValue);
      expect(restored.description, account.description);
    });
  });
}
