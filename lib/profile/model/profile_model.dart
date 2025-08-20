import 'package:invesly/database/table_schema.dart';

enum InveslyProfileAvatar {
  // enum values are name of the images in the assets/images/avatar folder
  man,
  woman,
  man2,
  woman2,
  man3,
  woman3;

  String get imgSrc => 'assets/images/avatar/$name.png';
}

class InveslyProfile extends ProfileInDb {
  InveslyProfile({required super.id, required super.name, required this.avatar, super.panNumber, super.aadhaarNumber})
    : super(avatarIndex: InveslyProfileAvatar.values.indexWhere((el) => el.imgSrc == avatar));

  final String avatar;

  factory InveslyProfile.fromDb(ProfileInDb profile) {
    int avatarIndex = profile.avatarIndex;
    if (avatarIndex < 0 || avatarIndex > InveslyProfileAvatar.values.length - 1) {
      avatarIndex = 2;
    }
    return InveslyProfile(
      id: profile.id,
      name: profile.name,
      avatar: InveslyProfileAvatar.values[avatarIndex].imgSrc,
      panNumber: profile.panNumber,
      aadhaarNumber: profile.aadhaarNumber,
    );
  }
}

class ProfileInDb extends InveslyDataModel {
  const ProfileInDb({
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

class ProfileTable extends TableSchema<ProfileInDb> {
  // Singleton pattern to ensure only one instance exists
  const ProfileTable._() : super('profiles');
  static const i = ProfileTable._();
  factory ProfileTable() => i;

  TableColumn<String> get nameColumn => TableColumn('name', name);
  TableColumn<int> get avatarColumn => TableColumn('avatar', name, type: TableColumnType.integer, isNullable: true);
  TableColumn<String> get panNumberColumn => TableColumn('pan_number', name, isNullable: true);
  TableColumn<String> get aadhaarNumberColumn => TableColumn('aadhaar_number', name, isNullable: true);

  @override
  Set<TableColumn> get columns =>
      super.columns..addAll([nameColumn, avatarColumn, panNumberColumn, aadhaarNumberColumn]);

  @override
  Map<String, dynamic> decode(ProfileInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      avatarColumn.title: data.avatarIndex,
      panNumberColumn.title: data.panNumber,
      aadhaarNumberColumn.title: data.aadhaarNumber,
    };
  }

  @override
  ProfileInDb encode(Map<String, dynamic> map) {
    return ProfileInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      avatarIndex: map[avatarColumn.title] as int,
      panNumber: map[panNumberColumn.title] as String?,
      aadhaarNumber: map[aadhaarNumberColumn.title] as String?,
    );
  }
}
