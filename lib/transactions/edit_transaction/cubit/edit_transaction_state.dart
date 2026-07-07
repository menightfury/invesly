// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'edit_transaction_cubit.dart';

enum EditTransactionStatus { initial, edited, error, saving, saved, failed }

class EditTransactionState extends Equatable {
  const EditTransactionState({
    this.status = EditTransactionStatus.initial,
    this.id,
    this.accountId,
    this.accountError,
    this.qnty,
    this.qntyError,
    this.rate,
    this.rateError,
    required this.totalAmount,
    this.totalAmountError,
    this.autoAmount = true,
    this.type = TransactionType.invested,
    this.genre = AmcGenre.mf,
    this.date,
    this.dateError,
    this.amc,
    this.amcError,
    this.notes,
  });

  final EditTransactionStatus status;
  final int? id;
  final int? accountId;
  final String? accountError;
  final double? qnty;
  final String? qntyError;
  final double? rate;
  final String? rateError;
  final double? totalAmount;
  final String? totalAmountError;
  final bool autoAmount;
  final TransactionType type;
  final AmcGenre genre;
  final DateTime? date;
  final String? dateError;
  final InveslyAmc? amc;
  final String? amcError;
  final String? notes;

  bool get isNewTransaction => id == null;

  bool get isAccountValid {
    if (accountId == null || accountError != null) return false;
    return !(accountId!.isNegative || accountId!.isInfinite || accountId!.isNaN);
  }

  bool get isDateValid => date != null && dateError == null;

  bool get isAmcValid => amc != null && amcError == null;

  bool get isRateValid => rate != null && rateError == null;

  bool get isQntyValid => qnty != null && qntyError == null;

  bool get isTotalAmountValid => totalAmount != null && totalAmountError == null;

  // Check if all required fields are filled and valid
  bool get isFormValid {
    return isAccountValid && isQntyValid && isRateValid && isDateValid && isAmcValid && isTotalAmountValid;
  }

  // check if unit rate and quantity fields can be edited
  bool get canEditRateAndQnty => [AmcGenre.stock, AmcGenre.mf].contains(genre);

  // check if total amount field can be edited
  bool get canEditAmount => !autoAmount || !canEditRateAndQnty;

  EditTransactionState copyWith({
    EditTransactionStatus? status,
    int? id,
    int? accountId,
    String? Function()? accountError,
    double? qnty,
    String? Function()? qntyError,
    double? rate,
    String? Function()? rateError,
    double? totalAmount,
    String? Function()? totalAmountError,
    bool? autoAmount,
    TransactionType? type,
    AmcGenre? genre,
    DateTime? date,
    String? Function()? dateError,
    InveslyAmc? amc,
    String? Function()? amcError,
    String? notes,
  }) {
    return EditTransactionState(
      status: status ?? this.status,
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      accountError: accountError != null ? accountError() : this.accountError, // Allows resetting to null
      qnty: qnty ?? this.qnty,
      qntyError: qntyError != null ? qntyError() : this.qntyError, // Allows resetting to null
      rate: rate ?? this.rate,
      rateError: rateError != null ? rateError() : this.rateError, // Allows resetting to null
      totalAmount: totalAmount ?? this.totalAmount,
      totalAmountError: totalAmountError != null
          ? totalAmountError()
          : this.totalAmountError, // Allows resetting to null
      autoAmount: autoAmount ?? this.autoAmount,
      type: type ?? this.type,
      genre: genre ?? this.genre,
      date: date ?? this.date,
      dateError: dateError != null ? dateError() : this.dateError, // Allows resetting to null
      amc: amc ?? this.amc,
      amcError: amcError != null ? amcError() : this.amcError, // Allows resetting to null
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    accountId,
    accountError,
    qnty,
    qntyError,
    rate,
    rateError,
    totalAmount,
    totalAmountError,
    autoAmount,
    type,
    genre,
    date,
    dateError,
    amc,
    amcError,
    notes,
  ];
}

extension EditTransactionStateX on EditTransactionState {
  bool get isError => status == EditTransactionStatus.error;
  bool get isEdited => [EditTransactionStatus.edited, EditTransactionStatus.error].contains(status);
  bool get isLoadingOrSuccess => [EditTransactionStatus.saving, EditTransactionStatus.saved].contains(status);
  bool get isFailureOrSuccess => [EditTransactionStatus.failed, EditTransactionStatus.saved].contains(status);
}
