import 'package:invesly/common_libs.dart';
import 'package:invesly/users/model/user_model.dart';

// delete users in production mode
final _user1 = UserInDb(id: $uuid.v1(), name: 'Satyajyoti Biswas', avatarIndex: 2);
final _user2 = UserInDb(id: $uuid.v1(), name: 'Jhuma Mondal', avatarIndex: 1);

final users = [_user1, _user2];
