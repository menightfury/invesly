import 'package:invesly/common_libs.dart';
import 'package:invesly/database/table_schema.dart';

enum InveslyAccountIcon {
  wallet(Icons.account_balance_wallet_rounded),
  savings(Icons.savings_rounded),
  card(Icons.credit_card_rounded),
  home(Icons.home_rounded),
  business(Icons.business_center_rounded),
  chart(Icons.show_chart_rounded),
  currency(Icons.currency_exchange_rounded),
  receipt(Icons.receipt_long_rounded);

  const InveslyAccountIcon(this.iconData);

  final IconData iconData;

  static InveslyAccountIcon? fromName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return values.firstWhereOrNull((icon) => icon.name == value);
  }
}

class InveslyAccount extends AccountInDb {
  InveslyAccount({required super.id, required super.name, super.description, this.icon, this.color})
    : super(iconName: icon?.name, colorValue: color?.toARGB32());

  InveslyAccount.empty({int? id, String? name, super.description, this.icon, this.color})
    : super(id: id ?? 0, name: name ?? 'Default', iconName: icon?.name, colorValue: color?.toARGB32());

  final InveslyAccountIcon? icon;
  final Color? color;

  factory InveslyAccount.fromDb(AccountInDb account) {
    return InveslyAccount(
      id: account.id,
      name: account.name,
      description: account.description,
      icon: InveslyAccountIcon.fromName(account.iconName),
      color: account.colorValue != null ? Color(account.colorValue!) : null,
    );
  }
}

class AccountInDb extends TableDataModel {
  const AccountInDb({required this.id, required this.name, this.description, this.iconName, this.colorValue});

  final int id;
  final String name;
  final String? description;
  final String? iconName;
  final int? colorValue;

  @override
  List<Object?> get props => [id, name, description, iconName, colorValue];
}

class AccountTable extends TableSchema<AccountInDb> {
  // Singleton pattern to ensure only one instance exists
  const AccountTable._() : super('accounts');
  static const instance = AccountTable._();
  factory AccountTable() => instance;

  TableColumn<int> get idColumn => TableColumn<int>('id', title, isPrimary: true, isAutoIncrement: true);
  TableColumn<String> get nameColumn => TableColumn<String>('name', title, isUnique: true);
  TableColumn<String> get descriptionColumn => TableColumn<String>('description', title, isNullable: true);
  TableColumn<String> get iconColumn => TableColumn<String>('icon', title, isNullable: true);
  TableColumn<int> get colorColumn => TableColumn<int>('color', title, isNullable: true);

  @override
  Set<TableColumn> get columns => {idColumn, nameColumn, descriptionColumn, iconColumn, colorColumn};

  @override
  Map<String, dynamic> fromModel(AccountInDb data) {
    return <String, dynamic>{
      idColumn.title: data.id,
      nameColumn.title: data.name,
      descriptionColumn.title: data.description,
      iconColumn.title: data.iconName,
      colorColumn.title: data.colorValue,
    };
  }

  @override
  AccountInDb fromMap(Map<String, dynamic> map) {
    return AccountInDb(
      id: map[idColumn.title] as int,
      name: map[nameColumn.title] as String,
      description: map[descriptionColumn.title] as String?,
      iconName: map[iconColumn.title] as String?,
      colorValue: map[colorColumn.title] as int?,
    );
  }
}
