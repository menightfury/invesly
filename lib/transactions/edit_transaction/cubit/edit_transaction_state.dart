// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_transaction_cubit.dart';

enum EditTransactionStatus { initial, edited, saving, saved, error }

// enum EditTransactionFieldStatus { initial, success, error }

class EditTransactionState extends Equatable {
  const EditTransactionState({
    this.status = EditTransactionStatus.initial,
    this.id,
    this.accountId,
    this.quantity,
    this.rate,
    required this.totalAmount,
    this.autoAmount = true,
    this.type = TransactionType.invested,
    this.genre = AmcGenre.mf,
    this.date,
    this.amc,
    this.notes,
  });

  final EditTransactionStatus status;
  final int? id;
  final int? accountId;
  final double? quantity;
  final double? rate;
  final double? totalAmount;
  final bool autoAmount;
  final TransactionType type;
  final AmcGenre genre;
  final DateTime? date;
  final InveslyAmc? amc;
  final String? notes;

  bool get isNewTransaction => id == null;

  // Check if all required fields are filled and valid
  bool get canSave {
    return accountId != null &&
        amc != null &&
        totalAmount != null &&
        (totalAmount?.isFinite ?? false) &&
        (totalAmount != 0);
  }

  // check if unit rate and quantity fields can be edited
  bool get canEditRateAndQnty => [AmcGenre.stock, AmcGenre.mf].contains(genre);

  // check if total amount field can be edited
  bool get canEditAmount => !autoAmount || !canEditRateAndQnty;

  EditTransactionState copyWith({
    EditTransactionStatus? status,
    InveslyTransaction? initialTransaction,
    int? accountId,
    double? quantity,
    double? rate,
    double? totalAmount,
    bool? autoAmount,
    TransactionType? type,
    AmcGenre? genre,
    DateTime? date,
    InveslyAmc? Function()? amc,
    String? notes,
  }) {
    return EditTransactionState(
      id: id,
      status: status ?? this.status,
      accountId: accountId ?? this.accountId,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      totalAmount: totalAmount ?? this.totalAmount,
      autoAmount: autoAmount ?? this.autoAmount,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      date: date ?? this.date,
      amc: amc != null ? amc() : this.amc,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    accountId,
    quantity,
    rate,
    totalAmount,
    autoAmount,
    type,
    genre,
    date,
    amc,
    notes,
  ];
}

extension EditTransactionStateX on EditTransactionState {
  bool get isLoadingOrSuccess => [EditTransactionStatus.saving, EditTransactionStatus.saved].contains(status);
  bool get isFailureOrSuccess => [EditTransactionStatus.error, EditTransactionStatus.saved].contains(status);
}
