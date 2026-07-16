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

  static InveslyAccountIcon fromName(String? value, {InveslyAccountIcon? fallback}) {
    if (value == null || value.isEmpty) {
      return fallback ?? wallet;
    }

    return values.firstWhere((icon) => icon.name == value, orElse: () => fallback ?? wallet);
  }
}

class InveslyAccount extends AccountInDb {
  const InveslyAccount({
    required super.id,
    required super.name,
    required super.iconName,
    required super.colorValue,
    super.description,
    double initialBalance = 0.0,
  }) : super(initialBalance: initialBalance);

  InveslyAccount.empty({
    int? id,
    String? name,
    String? iconName,
    int? colorValue,
    String? description,
    double? initialBalance,
  }) : super(
         id: id ?? 0,
         name: name ?? 'Default',
         iconName: iconName ?? InveslyAccountIcon.wallet.name,
         colorValue: colorValue ?? Colors.blueAccent.toARGB32(),
         description: description,
         initialBalance: initialBalance ?? 0.0,
       );

  Color get color => Color(colorValue);
  IconData get iconData => InveslyAccountIcon.fromName(iconName).iconData;

  Widget buildIconWidget({double size = 24.0, Color? backgroundColor, Color? foregroundColor, double? iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor ?? color.withAlpha(0x33), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(iconData, size: iconSize ?? size * 0.6, color: foregroundColor ?? color),
    );
  }

  factory InveslyAccount.fromDb(AccountInDb account) {
    return InveslyAccount(
      id: account.id,
      name: account.name,
      iconName: account.iconName,
      colorValue: account.colorValue,
      description: account.description,
      initialBalance: account.initialBalance,
    );
  }
}

class AccountInDb extends TableDataModel {
  const AccountInDb({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    this.description,
    this.initialBalance = 0.0,
  });

  final int id;
  final String name;
  final String iconName;
  final int colorValue;
  final String? description;
  final double initialBalance;

  @override
  List<Object?> get props => [id, name, iconName, colorValue, description, initialBalance];
}

class AccountTable extends TableSchema<AccountInDb> {
  // Singleton pattern to ensure only one instance exists
  const AccountTable._() : super('accounts');
  static const instance = AccountTable._();
  factory AccountTable() => instance;

  TableColumn<int> get idColumn => TableColumn<int>('id', tableName, isPrimary: true, isAutoIncrement: true);
  TableColumn<String> get nameColumn => TableColumn<String>('name', tableName);
  TableColumn<String> get iconColumn => TableColumn<String>('icon', tableName, isNullable: true);
  TableColumn<int> get colorColumn => TableColumn<int>('color', tableName, isNullable: true);
  TableColumn<String> get descriptionColumn => TableColumn<String>('description', tableName, isNullable: true);
  TableColumn<double> get initialBalanceColumn => TableColumn<double>('initial_balance', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => {
    idColumn,
    nameColumn,
    iconColumn,
    colorColumn,
    descriptionColumn,
    initialBalanceColumn,
  };

  @override
  Map<String, dynamic> fromModel(AccountInDb data) {
    return <String, dynamic>{
      if (!idColumn.isAutoIncrement) idColumn.title: data.id,
      nameColumn.title: data.name,
      iconColumn.title: data.iconName,
      colorColumn.title: data.colorValue,
      descriptionColumn.title: data.description,
      initialBalanceColumn.title: data.initialBalance,
    };
  }

  @override
  AccountInDb fromMap(Map<String, dynamic> map) {
    final rawColorValue = map[colorColumn.title];
    final rawInitialBalance = map[initialBalanceColumn.title];
    return AccountInDb(
      id: (map[idColumn.title] as num?)?.toInt() ?? 0,
      name: (map[nameColumn.title] as String?) ?? 'Default',
      iconName: (map[iconColumn.title] as String?) ?? InveslyAccountIcon.wallet.name,
      colorValue: rawColorValue is int
          ? rawColorValue
          : rawColorValue is num
          ? rawColorValue.toInt()
          : Colors.blueAccent.toARGB32(),
      description: map[descriptionColumn.title] as String?,
      initialBalance: rawInitialBalance is num ? rawInitialBalance.toDouble() : 0.0,
    );
  }
}
