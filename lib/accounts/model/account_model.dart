import 'package:invesly/database/table_schema.dart';

// enum values are name of the images in the assets/images/avatar folder
enum InveslyAccountAvatar {
  man,
  woman,
  man2,
  woman2,
  man3,
  woman3;

  String get imgSrc => 'assets/images/avatar/$name.png';

  static int indexOf(String? imgSrc) {
    if (imgSrc == null) return 0;

    final index = values.indexWhere((el) => el.imgSrc == imgSrc);
    return index != -1 ? index : 0;
  }
}

class InveslyAccount extends AccountInDb {
  InveslyAccount({required super.id, required super.name, required this.avatarSrc})
    : super(avatarIndex: InveslyAccountAvatar.indexOf(avatarSrc));

  InveslyAccount.empty({int? id, String? name, String? avatar})
    : avatarSrc = avatar ?? '',
      super(id: id ?? 0, name: name ?? 'Default', avatarIndex: InveslyAccountAvatar.indexOf(avatar));

  final String avatarSrc;

  factory InveslyAccount.fromDb(AccountInDb account) {
    int avatarIndex = account.avatarIndex;
    if (avatarIndex < 0 || avatarIndex > InveslyAccountAvatar.values.length - 1) {
      avatarIndex = 2;
    }
    return InveslyAccount(
      id: account.id,
      name: account.name,
      avatarSrc: InveslyAccountAvatar.values[avatarIndex].imgSrc,
    );
  }
}

class AccountInDb extends TableDataModel {
  const AccountInDb({required this.id, required this.name, required this.avatarIndex});

  final int id;
  final String name;
  final int avatarIndex;

  @override
  List<Object?> get props => [id, name, avatarIndex];
}

class AccountTable extends TableSchema<AccountInDb> {
  // Singleton pattern to ensure only one instance exists
  const AccountTable._() : super('accounts');
  static const instance = AccountTable._();
  factory AccountTable() => instance;

  TableColumn<int> get idColumn => TableColumn<int>('id', tableName, isPrimary: true, isAutoIncrement: true);
  TableColumn<String> get nameColumn => TableColumn<String>('name', tableName);
  TableColumn<int> get avatarColumn => TableColumn<int>('avatar', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => {idColumn, nameColumn, avatarColumn};

  @override
  Map<String, dynamic> fromModel(AccountInDb data) {
    return <String, dynamic>{
      if (!idColumn.isAutoIncrement) idColumn.title: data.id,
      nameColumn.title: data.name,
      avatarColumn.title: data.avatarIndex,
    };
  }

  @override
  AccountInDb fromMap(Map<String, dynamic> map) {
    return AccountInDb(
      id: map[idColumn.title] as int,
      name: map[nameColumn.title] as String,
      avatarIndex: map[avatarColumn.title] as int,
    );
  }
}
