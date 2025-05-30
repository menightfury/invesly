// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/database/table_schema.dart';

enum TransactionType { invested, redeemed }

class InveslyTransaction extends TransactionInDb {
  InveslyTransaction({
    required super.id,
    required super.userId,
    this.transactionType = TransactionType.invested,
    this.amc,
    super.quantity = 0.0,
    super.totalAmount = 0.0,
    required this.investedOn,
    super.note,
  }) : super(typeIndex: transactionType.index, amcId: amc?.id, date: investedOn.millisecondsSinceEpoch);

  final TransactionType transactionType;
  final InveslyAmc? amc;
  final DateTime investedOn;

  factory InveslyTransaction.fromDb(TransactionInDb trn, AmcInDb amc) {
    int typeIndex = trn.typeIndex;
    if (typeIndex < 0 || typeIndex > TransactionType.values.length - 1) {
      typeIndex = 0;
    }
    return InveslyTransaction(
      id: trn.id,
      userId: trn.userId,
      transactionType: TransactionType.values.elementAt(typeIndex),
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
    required this.userId,
    this.typeIndex = 0, // 0: invested, 1: redeemed
    this.amcId,
    this.quantity = 0.0,
    this.totalAmount = 0.0,
    required this.date,
    this.note,
  });

  final String userId;
  final int typeIndex;
  final String? amcId;
  final double quantity;
  // use totalAmount instead of unitRate,
  // because for dividend, while quantity will be 0, totalAmount will have some value
  final double totalAmount;
  final int date;
  final String? note;

  @override
  List<Object?> get props => super.props..addAll([userId, typeIndex, amcId, quantity, totalAmount, date, note]);

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

  TableColumn<String> get userIdColumn =>
      TableColumn('user_id', name, foreignReference: ForeignReference('users', 'id'));
  TableColumn<int> get typeColumn => TableColumn('type', name, type: TableColumnType.integer); // invested or redeemed
  TableColumn<String> get amcIdColumn =>
      TableColumn('amc_id', name, foreignReference: ForeignReference('amcs', 'id'), isNullable: true);
  TableColumn<double> get quantityColumn => TableColumn('quantity', name, type: TableColumnType.real);
  TableColumn<double> get amountColumn => TableColumn('total_amount', name, type: TableColumnType.real);
  TableColumn<int> get dateColumn => TableColumn('date', name, type: TableColumnType.integer);
  TableColumn<String> get noteColumn => TableColumn('note', name, isNullable: true);

  @override
  Set<TableColumn> get columns =>
      super.columns
        ..addAll([userIdColumn, amcIdColumn, quantityColumn, amountColumn, typeColumn, dateColumn, noteColumn]);

  @override
  Map<String, dynamic> decode(TransactionInDb data) {
    return <String, dynamic>{
      idColumn.title: data.id,
      userIdColumn.title: data.userId,
      typeColumn.title: data.typeIndex,
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
      userId: map[userIdColumn.title] as String,
      typeIndex: map[typeColumn.title] as int,
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
    required this.userId,
    required this.amcGenre,
    this.numTransactions = 0,
    this.totalAmount = 0.0,
  });

  final String userId;
  final AmcGenre amcGenre;
  final int numTransactions;
  final double totalAmount;

  @override
  List<Object?> get props => [userId, amcGenre, numTransactions, totalAmount];
}
