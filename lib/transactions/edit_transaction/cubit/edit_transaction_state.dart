// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_transaction_cubit.dart';

enum EditTransactionStatus { initial, loading, success, failure }

class EditTransactionState extends Equatable {
  const EditTransactionState({
    this.status = EditTransactionStatus.initial,
    this.id,
    this.account,
    this.quantity,
    this.rate,
    required this.amount,
    this.type = TransactionType.invested,
    this.genre = AmcGenre.stock,
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

  EditTransactionState copyWith({
    EditTransactionStatus? status,
    InveslyTransaction? initialTransaction,
    InveslyAccount? account,
    double? quantity,
    double? rate,
    double? amount,
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
      type: type ?? this.type,
      genre: genre ?? this.genre,
      date: date ?? this.date,
      amc: amc ?? this.amc,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [status, id, account, quantity, rate, amount, type, genre, date, amc, notes];
}

extension EditTransactionStateX on EditTransactionState {
  bool get isLoadingOrSuccess => [EditTransactionStatus.loading, EditTransactionStatus.success].contains(status);
  bool get isFailureOrSuccess => [EditTransactionStatus.failure, EditTransactionStatus.success].contains(status);
}
