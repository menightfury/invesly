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
    this.accountColumn,
    this.dateColumn,
    this.categoryColumn,
    this.notesColumn,
    this.titleColumn,
    this.defaultAccount,
    this.errorMsg,
  });

  final ImportTransactionsStatus status;
  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  // final Map<CsvColumn, int?> columns;
  final int? amountColumn, accountColumn, dateColumn, categoryColumn, notesColumn, titleColumn;
  final InveslyAccount? defaultAccount;
  final String? errorMsg;

  ImportTransactionsState copyWith({
    ImportTransactionsStatus? status,
    List<String>? csvHeaders,
    List<List<dynamic>>? csvData,
    int? amountColumn,
    int? accountColumn,
    int? dateColumn,
    int? categoryColumn,
    int? notesColumn,
    int? titleColumn,
    InveslyAccount? defaultAccount,
    String? errorMsg,
  }) {
    return ImportTransactionsState(
      status: status ?? this.status,
      csvHeaders: csvHeaders ?? this.csvHeaders,
      csvData: csvData ?? this.csvData,
      amountColumn: amountColumn ?? this.amountColumn,
      accountColumn: accountColumn ?? this.accountColumn,
      dateColumn: dateColumn ?? this.dateColumn,
      categoryColumn: categoryColumn ?? this.categoryColumn,
      notesColumn: notesColumn ?? this.notesColumn,
      titleColumn: titleColumn ?? this.titleColumn,
      defaultAccount: defaultAccount ?? this.defaultAccount,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [
    csvHeaders,
    csvData,
    amountColumn,
    accountColumn,
    dateColumn,
    categoryColumn,
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
