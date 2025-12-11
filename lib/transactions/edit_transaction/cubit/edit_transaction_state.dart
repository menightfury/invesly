// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_transaction_cubit.dart';

enum EditTransactionStatus { initial, edited, loading, success, failure }

class EditTransactionState extends Equatable {
  const EditTransactionState({
    this.status = EditTransactionStatus.initial,
    this.id,
    this.account,
    this.quantity,
    this.rate,
    required this.amount,
    this.autoAmount = true,
    this.type = TransactionType.invested,
    this.genre = AmcGenre.mf,
    this.date,
    this.amc,
    this.notes,
  });

  final EditTransactionStatus status;
  final String? id;
  final InveslyAccount? account;
  final double? quantity;
  final double? rate;
  final double? amount;
  final bool autoAmount;
  final TransactionType type;
  final AmcGenre genre;
  final DateTime? date;
  final InveslyAmc? amc;
  final String? notes;

  bool get isNewTransaction => id == null;

  // Check if all required fields are filled and valid
  bool get canSave {
    return account != null &&
        amount != null &&
        (amount?.isFinite ?? false) &&
        !(amount?.isNegative ?? true) &&
        !(amount?.isZero ?? true);
  }

  // check if unit rate and quantity fields can be edited
  bool get canEditRateAndQnty => [AmcGenre.stock, AmcGenre.mf].contains(genre);

  // check if total amount field can be edited
  bool get canEditAmount => !autoAmount || !canEditRateAndQnty;

  EditTransactionState copyWith({
    EditTransactionStatus? status,
    InveslyTransaction? initialTransaction,
    InveslyAccount? account,
    double? quantity,
    double? rate,
    double? amount,
    bool? autoAmount,
    TransactionType? type,
    AmcGenre? genre,
    DateTime? date,
    InveslyAmc? amc,
    String? notes,
  }) {
    return EditTransactionState(
      id: id,
      status: status ?? this.status,
      account: account ?? this.account,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      autoAmount: autoAmount ?? this.autoAmount,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      date: date ?? this.date,
      amc: amc ?? this.amc,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [status, id, account, quantity, rate, amount, autoAmount, type, genre, date, amc, notes];
}

extension EditTransactionStateX on EditTransactionState {
  bool get isLoadingOrSuccess => [EditTransactionStatus.loading, EditTransactionStatus.success].contains(status);
  bool get isFailureOrSuccess => [EditTransactionStatus.failure, EditTransactionStatus.success].contains(status);
}
