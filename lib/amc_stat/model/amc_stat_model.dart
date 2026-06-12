// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/amcs/model/latest_xirr_model.dart';
import 'package:invesly/database/table_schema.dart';

// ~ Data Model
class StatInDb extends TableDataModel {
  const StatInDb({
    required this.accountId,
    required this.amcId,
    required this.numTransactions,
    this.totalQuantity = 0.0,
    this.totalInvested = 0.0,
    this.totalRedeemed = 0.0,
    this.xirrString,
  });

  final int accountId;
  final String amcId;
  final int numTransactions;
  final double totalQuantity;
  final double totalInvested;
  final double totalRedeemed;
  final String? xirrString;

  double get averageBuyPrice {
    if (totalQuantity == 0) {
      return 0.0;
    }
    return totalInvested / totalQuantity;
  }

  @override
  List<Object?> get props {
    return [accountId, amcId, numTransactions, totalQuantity, totalInvested, totalRedeemed, xirrString];
  }

  StatInDb copyWith({
    int? accountId,
    String? amcId,
    int? numTransactions,
    double? totalQuantity,
    double? totalInvested,
    double? totalRedeemed,
    String? xirrString,
  }) {
    return StatInDb(
      accountId: accountId ?? this.accountId,
      amcId: amcId ?? this.amcId,
      numTransactions: numTransactions ?? this.numTransactions,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalInvested: totalInvested ?? this.totalInvested,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      xirrString: xirrString ?? this.xirrString,
    );
  }
}

class InveslyStat extends StatInDb {
  InveslyStat({
    required this.account,
    required this.amc,
    super.numTransactions = 0,
    super.totalQuantity = 0.0,
    super.totalInvested = 0.0,
    super.totalRedeemed = 0.0,
    this.xirr,
  }) : super(accountId: account.id, amcId: amc.id, xirrString: xirr?.toJson());

  final InveslyAccount account;
  final InveslyAmc amc;

  /// Latest calculated xirr
  final LatestXirr? xirr;

  factory InveslyStat.fromDb(StatInDb stat, AccountInDb account, AmcInDb amc) {
    LatestXirr? xirr;
    if (stat.xirrString?.isNotEmpty ?? false) {
      xirr = LatestXirr.fromJson(stat.xirrString!);
    }

    return InveslyStat(
      account: InveslyAccount.fromDb(account),
      amc: InveslyAmc.fromDb(amc),
      numTransactions: stat.numTransactions,
      totalQuantity: stat.totalQuantity,
      totalInvested: stat.totalInvested,
      totalRedeemed: stat.totalRedeemed,
      xirr: xirr,
    );
  }

  @override
  List<Object?> get props => super.props..addAll([account, amc, xirr]);
}

// ~ Table Model
class StatTable extends TableSchema<StatInDb> {
  // Singleton pattern to ensure only one instance exists
  const StatTable._() : super('stats');
  static const instance = StatTable._();
  factory StatTable() => instance;

  TableColumn<int> get accountIdColumn =>
      TableColumn('account_id', tableName, foreignReference: ForeignReference('accounts', 'id'));
  TableColumn<String> get amcIdColumn =>
      TableColumn('amc_id', tableName, foreignReference: ForeignReference('amcs', 'id'));
  TableColumn<int> get numTransactionsColumn => TableColumn('num_transactions', tableName);
  TableColumn<double> get totalQuantityColumn => TableColumn('total_quantity', tableName);
  TableColumn<double> get totalInvestedColumn => TableColumn('total_invested', tableName);
  TableColumn<double> get totalRedeemedColumn => TableColumn('total_redeemed', tableName);
  TableColumn<String> get xirrColumn => TableColumn('xirr', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => {
    accountIdColumn,
    amcIdColumn,
    numTransactionsColumn,
    totalQuantityColumn,
    totalInvestedColumn,
    totalRedeemedColumn,
    xirrColumn,
  };

  @override
  Map<String, dynamic> fromModel(StatInDb data) {
    return <String, dynamic>{
      accountIdColumn.title: data.accountId,
      amcIdColumn.title: data.amcId,
      numTransactionsColumn.title: data.numTransactions,
      totalQuantityColumn.title: data.totalQuantity,
      totalInvestedColumn.title: data.totalInvested,
      totalRedeemedColumn.title: data.totalRedeemed,
      xirrColumn.title: data.xirrString,
    };
  }

  @override
  StatInDb fromMap(Map<String, dynamic> map) {
    return StatInDb(
      accountId: map[accountIdColumn.title] as int,
      amcId: map[amcIdColumn.title] as String,
      numTransactions: map[numTransactionsColumn.title] as int,
      totalQuantity: map[totalQuantityColumn.title] as double,
      totalInvested: map[totalInvestedColumn.title] as double,
      totalRedeemed: map[totalRedeemedColumn.title] as double,
      xirrString: map[xirrColumn.title] as String?,
    );
  }
}
