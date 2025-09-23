import 'package:invesly/database/table_schema.dart';

enum InveslyAccountAvatar {
  // enum values are name of the images in the assets/images/avatar folder
  man,
  woman,
  man2,
  woman2,
  man3,
  woman3;

  String get imgSrc => 'assets/images/avatar/$name.png';
}

class InveslyAccount extends AccountInDb {
  InveslyAccount({required super.id, required super.name, required this.avatar})
    : super(avatarIndex: InveslyAccountAvatar.values.indexWhere((el) => el.imgSrc == avatar));

  // const InveslyAccount.empty() : avatar = '', super(id: '', name: '', avatarIndex: 0);

  final String avatar;

  factory InveslyAccount.fromDb(AccountInDb account) {
    int avatarIndex = account.avatarIndex;
    if (avatarIndex < 0 || avatarIndex > InveslyAccountAvatar.values.length - 1) {
      avatarIndex = 2;
    }
    return InveslyAccount(
      id: account.id,
      name: account.name,
      avatar: InveslyAccountAvatar.values[avatarIndex].imgSrc,
      // panNumber: account.panNumber,
      // aadhaarNumber: account.aadhaarNumber,
    );
  }
}

class AccountInDb extends InveslyDataModel {
  const AccountInDb({
    required super.id,
    required this.name,
    required this.avatarIndex,
    // this.panNumber,
    // this.aadhaarNumber,
  });

  final String name;
  final int avatarIndex;
  // final String? panNumber;
  // final String? aadhaarNumber;

  @override
  List<Object?> get props => super.props..addAll([name, avatarIndex]);
}

class AccountTable extends TableSchema<AccountInDb> {
  // Singleton pattern to ensure only one instance exists
  const AccountTable._() : super('accounts');
  static const i = AccountTable._();
  factory AccountTable() => i;

  TableColumn<String> get nameColumn => TableColumn('name', name);
  TableColumn<int> get avatarColumn => TableColumn('avatar', name, type: TableColumnType.integer, isNullable: true);
  // TableColumn<String> get panNumberColumn => TableColumn('pan_number', name, isNullable: true);
  // TableColumn<String> get aadhaarNumberColumn => TableColumn('aadhaar_number', name, isNullable: true);

  @override
  Set<TableColumn> get columns => super.columns..addAll([nameColumn, avatarColumn]);

  @override
  Map<String, dynamic> decode(AccountInDb data) {
    return {
      idColumn.title: data.id,
      nameColumn.title: data.name,
      avatarColumn.title: data.avatarIndex,
      // panNumberColumn.title: data.panNumber,
      // aadhaarNumberColumn.title: data.aadhaarNumber,
    };
  }

  @override
  AccountInDb encode(Map<String, dynamic> map) {
    return AccountInDb(
      id: map[idColumn.title] as String,
      name: map[nameColumn.title] as String,
      avatarIndex: map[avatarColumn.title] as int,
      // panNumber: map[panNumberColumn.title] as String?,
      // aadhaarNumber: map[aadhaarNumberColumn.title] as String?,
    );
  }
}
