import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/model/account_model.dart';

// delete accounts in production mode
final _account1 = AccountInDb(id: $uuid.v1(), name: 'Satyajyoti Biswas', avatarIndex: 2);
final _account2 = AccountInDb(id: $uuid.v1(), name: 'Jhuma Mondal', avatarIndex: 1);

final accounts = [_account1, _account2];
