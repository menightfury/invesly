// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/table_schema.dart';

enum TransactionType {
  invested,
  redeemed,
  dividend;

  IconData get icon {
    return switch (this) {
      invested => Icons.north_east_rounded,
      _ => Icons.south_west_rounded,
    };
  }

  static TransactionType? fromCode(int value) {
    return values.singleWhereOrNull((type) => type.index == value);
  }

  static TransactionType? fromChar(String value) {
    final $value = value.trim();
    if ($value.isEmpty) return null;

    final $char = $value.toLowerCase();
    return switch ($char) {
      'i' => invested,
      'r' => redeemed,
      'd' => dividend,
      _ => null,
    };
  }

  static TransactionType? fromString(String value) {
    final $value = value.trim();
    if ($value.isEmpty) return null;

    final $string = $value.toLowerCase();
    return values.firstWhereOrNull((type) => type.name.toLowerCase() == $string);
  }

  Color color(BuildContext context) {
    return switch (this) {
      invested => Colors.deepOrange,
      redeemed => Colors.teal,
      dividend => Colors.blueAccent,
    };
  }
}

class InveslyTransaction extends TransactionInDb {
  InveslyTransaction({
    required super.id,
    required this.account,
    // required super.accountId,
    // this.transactionType = TransactionType.invested,
    this.amc,
    super.quantity = 0.0,
    super.totalAmount = 0.0,
    required this.investedOn,
    super.note,
    // }) : super(typeIndex: transactionType.index, amcId: amc?.id, date: investedOn.millisecondsSinceEpoch);
  }) : transactionType = totalAmount > 0
           ? TransactionType.invested
           : quantity > 0
           ? TransactionType.redeemed
           : TransactionType.dividend,
       super(accountId: account.id, amcId: amc?.id, date: investedOn.millisecondsSinceEpoch);

  final InveslyAccount account;
  final TransactionType transactionType;
  final InveslyAmc? amc;
  final DateTime investedOn;

  factory InveslyTransaction.fromDb(TransactionInDb trn, AccountInDb account, AmcInDb amc) {
    // int typeIndex = trn.typeIndex;
    // if (typeIndex < 0 || typeIndex > TransactionType.values.length - 1) {
    //   typeIndex = 0;
    // }
    return InveslyTransaction(
      id: trn.id,
      account: InveslyAccount.fromDb(account),
      // accountId: trn.accountId,
      // transactionType: TransactionType.values.elementAt(typeIndex),
      amc: InveslyAmc.fromDb(amc),
      quantity: trn.quantity,
      totalAmount: trn.totalAmount,
      investedOn: DateTime.fromMillisecondsSinceEpoch(trn.date),
      note: trn.note,
    );
  }

  @override
  List<Object?> get props => super.props..addAll([transactionType, amc, investedOn]);

  // @override
  // InveslyTransaction copyWith({
  //   String? userId,
  //   String? amcId,
  //   InveslyAmc? amc,
  //   double? quantity,
  //   double? totalAmount,
  //   DateTime? investedOn,
  //   String? note,
  // }) {
  //   return InveslyTransaction(
  //     id: id,
  //     userId: userId ?? this.userId,
  //     amc: amc ?? this.amc,
  //     quantity: quantity ?? this.quantity,
  //     totalAmount: totalAmount ?? this.totalAmount,
  //     investedOn: investedOn ?? this.investedOn,
  //     note: note ?? this.note,
  //   );
  // }
}

class TransactionInDb extends InveslyDataModel {
  const TransactionInDb({
    required super.id,
    required this.accountId,
    // this.typeIndex = 0, // 0: invested, 1: redeemed
    this.amcId,
    this.quantity = 0.0,
    this.totalAmount = 0.0,
    required this.date,
    this.note,
  });

  final String accountId;
  // final int typeIndex;
  final String? amcId;
  final double quantity;
  // use totalAmount instead of unitRate,
  // because for dividend, while quantity will be 0, totalAmount will have some value
  final double totalAmount;
  final int date;
  final String? note;

  @override
  List<Object?> get props => super.props..addAll([accountId, amcId, quantity, totalAmount, date, note]);

  // TransactionInDb copyWith({
  //   String? userId,
  //   int? type,
  //   String? amcId,
  //   double? quantity,
  //   double? totalAmount,
  //   int? date,
  //   String? note,
  // }) {
  //   return TransactionInDb(
  //     id: id,
  //     userId: userId ?? this.userId,
  //     type: type ?? this.type,
  //     amcId: amcId ?? this.amcId,
  //     quantity: quantity ?? this.quantity,
  //     totalAmount: totalAmount ?? this.totalAmount,
  //     date: date ?? this.date,
  //     note: note ?? this.note,
  //   );
  // }
}

class TransactionTable extends TableSchema<TransactionInDb> {
  // Singleton pattern to ensure only one instance exists
  const TransactionTable._() : super('transactions');
  static final _i = TransactionTable._();
  factory TransactionTable() => _i;

  TableColumn<String> get accountIdColumn =>
      TableColumn('account_id', tableName, foreignReference: ForeignReference('accounts', 'id'));
  // TableColumn<int> get typeColumn => TableColumn('type', name, type: TableColumnType.integer); // invested or redeemed
  TableColumn<String> get amcIdColumn =>
      TableColumn('amc_id', tableName, foreignReference: ForeignReference('amcs', 'id'), isNullable: true);
  TableColumn<double> get quantityColumn => TableColumn('quantity', tableName, type: TableColumnType.real);
  TableColumn<double> get amountColumn => TableColumn('total_amount', tableName, type: TableColumnType.real);
  TableColumn<int> get dateColumn => TableColumn('date', tableName, type: TableColumnType.integer);
  TableColumn<String> get noteColumn => TableColumn('note', tableName, isNullable: true);

  @override
  Set<TableColumn> get columns =>
      super.columns..addAll([accountIdColumn, amcIdColumn, quantityColumn, amountColumn, dateColumn, noteColumn]);

  @override
  Map<String, dynamic> decode(TransactionInDb data) {
    return <String, dynamic>{
      idColumn.title: data.id,
      accountIdColumn.title: data.accountId,
      // typeColumn.title: data.typeIndex,
      amcIdColumn.title: data.amcId,
      quantityColumn.title: data.quantity,
      amountColumn.title: data.totalAmount,
      dateColumn.title: data.date,
      noteColumn.title: data.note,
    };
  }

  @override
  TransactionInDb encode(Map<String, dynamic> map) {
    return TransactionInDb(
      id: map[idColumn.title] as String,
      accountId: map[accountIdColumn.title] as String,
      // typeIndex: map[typeColumn.title] as int,
      amcId: map[amcIdColumn.title] as String?,
      quantity: (map[quantityColumn.title] as num).toDouble(),
      totalAmount: (map[amountColumn.title] as num).toDouble(),
      date: map[dateColumn.title] as int,
      note: map[noteColumn.title] as String?,
    );
  }
}

class TransactionStat extends Equatable {
  const TransactionStat({
    required this.accountId,
    required this.amcGenre,
    this.numTransactions = 0,
    this.totalAmount = 0.0,
  });

  final String accountId;
  final AmcGenre amcGenre;
  final int numTransactions;
  final double totalAmount;

  @override
  List<Object?> get props => [accountId, amcGenre, numTransactions, totalAmount];
}
