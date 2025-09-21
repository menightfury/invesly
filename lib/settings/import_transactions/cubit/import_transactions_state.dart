part of 'import_transactions_cubit.dart';

// enum CsvColumn { amount, account, date, category, notes, title }
enum ImportTransactionsStatus { initial, loading, loaded, error }

class ImportTransactionsState extends Equatable {
  const ImportTransactionsState({
    this.status = ImportTransactionsStatus.initial,
    this.csvHeaders = const [],
    this.csvData = const [],
    // this.columns = const {},
    this.amountColumn,
    this.quantityColumn,
    this.accountColumn,
    this.dateColumn,
    this.typeColumn,
    this.notesColumn,
    this.titleColumn,
    this.defaultAccount,
    this.defaultType = TransactionType.invested,
    this.errorMsg,
  });

  final ImportTransactionsStatus status;
  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  // final Map<CsvColumn, int?> columns;
  final int? amountColumn, quantityColumn, accountColumn, dateColumn, typeColumn, notesColumn, titleColumn;
  final InveslyAccount? defaultAccount;
  final TransactionType defaultType;
  final String? errorMsg;

  ImportTransactionsState copyWith({
    ImportTransactionsStatus? status,
    List<String>? csvHeaders,
    List<List<dynamic>>? csvData,
    int? amountColumn,
    int? quantityColumn,
    int? accountColumn,
    int? dateColumn,
    int? typeColumn,
    int? notesColumn,
    int? titleColumn,
    InveslyAccount? defaultAccount,
    TransactionType? defaultType,
    String? errorMsg,
  }) {
    return ImportTransactionsState(
      status: status ?? this.status,
      csvHeaders: csvHeaders ?? this.csvHeaders,
      csvData: csvData ?? this.csvData,
      amountColumn: amountColumn ?? this.amountColumn,
      quantityColumn: quantityColumn ?? this.quantityColumn,
      accountColumn: accountColumn ?? this.accountColumn,
      dateColumn: dateColumn ?? this.dateColumn,
      typeColumn: typeColumn ?? this.typeColumn,
      notesColumn: notesColumn ?? this.notesColumn,
      titleColumn: titleColumn ?? this.titleColumn,
      defaultAccount: defaultAccount ?? this.defaultAccount,
      defaultType: defaultType ?? this.defaultType,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [
    csvHeaders,
    csvData,
    amountColumn,
    quantityColumn,
    accountColumn,
    dateColumn,
    typeColumn,
    notesColumn,
    titleColumn,
    defaultAccount,
    errorMsg,
  ];

  @override
  bool? get stringify => true;
}

extension ImportTransactionsStateX on ImportTransactionsState {
  //   bool get isLoading => this is ImportTransactionsInitialState || this is ImportTransactionsLoadingState;
  bool get isLoading => status == ImportTransactionsStatus.initial || status == ImportTransactionsStatus.loading;
  //   bool get isLoaded => this is ImportTransactionsLoadedState;
  bool get isLoaded => status == ImportTransactionsStatus.loaded;
  //   bool get isError => this is ImportTransactionsErrorState;
  bool get isError => status == ImportTransactionsStatus.error;
}
