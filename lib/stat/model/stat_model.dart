// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/table_schema.dart';

// ~ Data Model
class StatInDb extends TableDataModel {
  const StatInDb({
    required this.accountId,
    required this.amcId,
    required this.numTrns,
    this.totalQnty = 0.0,
    this.totalInvested = 0.0,
    this.totalRedeemed = 0.0,
    this.xirr,
  });

  final int accountId;
  final String amcId;
  final int numTrns;
  final double totalQnty;
  final double totalInvested;
  final double totalRedeemed;
  final double? xirr;

  double get averageBuyPrice {
    if (totalQnty == 0) {
      return 0.0;
    }
    return totalInvested / totalQnty;
  }

  @override
  List<Object?> get props {
    return [accountId, amcId, numTrns, totalQnty, totalInvested, totalRedeemed, xirr];
  }

  StatInDb copyWith({
    int? accountId,
    String? amcId,
    int? numTrns,
    double? totalQnty,
    double? totalInvested,
    double? totalRedeemed,
    double? xirr,
  }) {
    return StatInDb(
      accountId: accountId ?? this.accountId,
      amcId: amcId ?? this.amcId,
      numTrns: numTrns ?? this.numTrns,
      totalQnty: totalQnty ?? this.totalQnty,
      totalInvested: totalInvested ?? this.totalInvested,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      xirr: xirr ?? this.xirr,
    );
  }
}

class InveslyStat extends StatInDb {
  InveslyStat({
    required super.accountId,
    required this.amc,
    super.numTrns = 0,
    super.totalQnty = 0.0,
    super.totalInvested = 0.0,
    super.totalRedeemed = 0.0,
    super.xirr,
  }) : super(amcId: amc.id);

  // final InveslyAccount account;
  final InveslyAmc amc;

  factory InveslyStat.fromDb(StatInDb stat, AmcInDb amc) {
    // LatestXirr? xirr;
    // if (stat.this.xirr?.isNotEmpty ?? false) {
    //   xirr = LatestXirr.fromJson(stat.this.xirr!);
    // }

    return InveslyStat(
      accountId: stat.accountId,
      amc: InveslyAmc.fromDb(amc),
      numTrns: stat.numTrns,
      totalQnty: stat.totalQnty,
      totalInvested: stat.totalInvested,
      totalRedeemed: stat.totalRedeemed,
      xirr: stat.xirr,
    );
  }

  @override
  List<Object?> get props => super.props..add(amc);
}

// ~ Table Model
class StatTable extends TableSchema<StatInDb> {
  // Singleton pattern to ensure only one instance exists
  const StatTable._() : super('stats');
  static const instance = StatTable._();
  factory StatTable() => instance;

  TableColumn<int> get accountIdColumn =>
      TableColumn('account_id', tableName, isPrimary: true, foreignReference: ForeignReference('accounts', 'id'));
  TableColumn<String> get amcIdColumn =>
      TableColumn('amc_id', tableName, isPrimary: true, foreignReference: ForeignReference('amcs', 'id'));
  TableColumn<int> get numTrnsColumn => TableColumn('num_transactions', tableName);
  TableColumn<double> get totalQntyColumn => TableColumn('total_quantity', tableName);
  TableColumn<double> get totalInvestedColumn => TableColumn('total_invested', tableName);
  TableColumn<double> get totalRedeemedColumn => TableColumn('total_redeemed', tableName);
  TableColumn<String> get xirrColumn => TableColumn('xirr', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns => {
    accountIdColumn,
    amcIdColumn,
    numTrnsColumn,
    totalQntyColumn,
    totalInvestedColumn,
    totalRedeemedColumn,
    xirrColumn,
  };

  @override
  Map<String, dynamic> fromModel(StatInDb data) {
    return <String, dynamic>{
      accountIdColumn.title: data.accountId,
      amcIdColumn.title: data.amcId,
      numTrnsColumn.title: data.numTrns,
      totalQntyColumn.title: data.totalQnty,
      totalInvestedColumn.title: data.totalInvested,
      totalRedeemedColumn.title: data.totalRedeemed,
      xirrColumn.title: data.xirr,
    };
  }

  @override
  StatInDb fromMap(Map<String, dynamic> map) {
    return StatInDb(
      accountId: map[accountIdColumn.title] as int,
      amcId: map[amcIdColumn.title] as String,
      numTrns: map[numTrnsColumn.title] as int,
      totalQnty: map[totalQntyColumn.title] as double,
      totalInvested: map[totalInvestedColumn.title] as double,
      totalRedeemed: map[totalRedeemedColumn.title] as double,
      xirr: map[xirrColumn.title] as double?,
    );
  }
}
