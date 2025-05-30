import 'package:invesly/database/table_schema.dart';

enum InveslyUserAvatar {
  // enum values are name of the images in the assets/images/avatar folder
  man,
  woman,
  man2,
  woman2,
  man3,
  woman3;

  String get imgSrc => 'assets/images/avatar/$name.png';
}

class InveslyUser extends UserInDb {
  InveslyUser({required super.id, required super.name, required this.avatar, super.panNumber, super.aadhaarNumber})
    : super(avatarIndex: InveslyUserAvatar.values.indexWhere((el) => el.imgSrc == avatar));

  final String avatar;

  factory InveslyUser.fromDb(UserInDb user) {
    int avatarIndex = user.avatarIndex;
    if (avatarIndex < 0 || avatarIndex > InveslyUserAvatar.values.length - 1) {
      avatarIndex = 2;
    }
    return InveslyUser(
      id: user.id,
      name: user.name,
      avatar: InveslyUserAvatar.values[avatarIndex].imgSrc,
      panNumber: user.panNumber,
      aadhaarNumber: user.aadhaarNumber,
    );
  }
}

class UserInDb extends InveslyDataModel {
  const UserInDb({
    required super.id,
    required this.name,
    required this.avatarIndex,
    this.panNumber,
    this.aadhaarNumber,
  });

  final String name;
  final int avatarIndex;
  final String? panNumber;
  final String? aadhaarNumber;

  @override
  List<Object?> get props => super.props..addAll([name, avatarIndex, panNumber, aadhaarNumber]);
}

class UserTable extends TableSchema<UserInDb> {
  // Singleton pattern to ensure only one instance exists
  const UserTable._() : super('users');
  static const i = UserTable._();
  factory UserTable() => i;

  TableColumn<String> get nameColumn => TableColumn('name', name);
  TableColumn<int> get avatarColumn => TableColumn('avatar', name, type: TableColumnType.integer, isNullable: true);
  TableColumn<String> get panNumberColumn => TableColumn('pan_number', name, isNullable: true);
  TableColumn<String> get aadhaarNumberColumn => TableColumn('aadhaar_number', name, isNullable: true);

  @override
  Set<TableColumn> get columns =>
      super.columns..addAll([nameColumn, avatarColumn, panNumberColumn, aadhaarNumberColumn]);

  @override
  Map<String, dynamic> decode(UserInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      avatarColumn.title: data.avatarIndex,
      panNumberColumn.title: data.panNumber,
      aadhaarNumberColumn.title: data.aadhaarNumber,
    };
  }

  @override
  UserInDb encode(Map<String, dynamic> map) {
    return UserInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      avatarIndex: map[avatarColumn.title] as int,
      panNumber: map[panNumberColumn.title] as String?,
      aadhaarNumber: map[aadhaarNumberColumn.title] as String?,
    );
  }
}
