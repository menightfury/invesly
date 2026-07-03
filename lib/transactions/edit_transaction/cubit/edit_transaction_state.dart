// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_transaction_cubit.dart';

enum EditTransactionStatus { initial, edited, saving, saved, error }

// enum EditTransactionFormFieldStatus { initial, success, error }

class EditTransactionState extends Equatable {
  const EditTransactionState({
    this.status = EditTransactionStatus.initial,
    this.id,
    this.accountId,
    this.accountStatus,
    this.qnty,
    this.qntyStatus,
    this.rate,
    this.rateStatus,
    required this.totalAmount,
    this.totalAmountStatus,
    this.autoAmount = true,
    this.type = TransactionType.invested,
    this.genre = AmcGenre.mf,
    this.date,
    this.dateStatus,
    this.amc,
    this.amcStatus,
    this.notes,
  });

  final EditTransactionStatus status;
  final int? id;
  final int? accountId;
  final String? accountStatus;
  final double? qnty;
  final String? qntyStatus;
  final double? rate;
  final String? rateStatus;
  final double? totalAmount;
  final String? totalAmountStatus;
  final bool autoAmount;
  final TransactionType type;
  final AmcGenre genre;
  final DateTime? date;
  final String? dateStatus;
  final InveslyAmc? amc;
  final String? amcStatus;
  final String? notes;

  bool get isNewTransaction => id == null;

  // Check if all required fields are filled and valid
  bool get isFormValid {
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
    int? id,
    int? accountId,
    String? accountStatus,
    double? qnty,
    String? qntyStatus,
    double? rate,
    String? rateStatus,
    double? totalAmount,
    String? totalAmountStatus,
    bool? autoAmount,
    TransactionType? type,
    AmcGenre? genre,
    DateTime? date,
    String? dateStatus,
    InveslyAmc? amc,
    String? amcStatus,
    String? notes,
  }) {
    return EditTransactionState(
      status: status ?? this.status,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountStatus: accountStatus, // Allows resetting to null
      qnty: qnty ?? this.qnty,
      qntyStatus: qntyStatus, // Allows resetting to null
      rate: rate ?? this.rate,
      rateStatus: rateStatus, // Allows resetting to null
      totalAmount: totalAmount ?? this.totalAmount,
      totalAmountStatus: totalAmountStatus, // Allows resetting to null
      autoAmount: autoAmount ?? this.autoAmount,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      date: date ?? this.date,
      dateStatus: dateStatus, // Allows resetting to null
      amc: amc ?? this.amc,
      amcStatus: amcStatus, // Allows resetting to null
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    accountId,
    accountStatus,
    qnty,
    qntyStatus,
    rate,
    rateStatus,
    totalAmount,
    totalAmountStatus,
    autoAmount,
    type,
    genre,
    date,
    dateStatus,
    amc,
    amcStatus,
    notes,
  ];
}

extension EditTransactionStateX on EditTransactionState {
  bool get isLoadingOrSuccess => [EditTransactionStatus.saving, EditTransactionStatus.saved].contains(status);
  bool get isFailureOrSuccess => [EditTransactionStatus.error, EditTransactionStatus.saved].contains(status);
}
