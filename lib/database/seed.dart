import 'package:invesly/common_libs.dart';
import 'package:invesly/profile/model/profile_model.dart';

// delete profiles in production mode
final _profile1 = ProfileInDb(id: $uuid.v1(), name: 'Satyajyoti Biswas', avatarIndex: 2);
final _profile2 = ProfileInDb(id: $uuid.v1(), name: 'Jhuma Mondal', avatarIndex: 1);

final profiles = [_profile1, _profile2];
