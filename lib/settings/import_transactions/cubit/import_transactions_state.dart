part of 'import_transactions_cubit.dart';

// This approach leads to unnecessary rebuilds of widgets that depend on the state.
// Consider using more granular state management or separating state into smaller parts.
enum TransactionField {
  amount,
  quantity,
  account,
  amc,
  type,
  date,
  notes,

  // String? get validator {
  //   if (this == amc) {
  //     return 'AMC is provided as .... but AMC not found in database.';
  //   }

  //   return null;
  // }
}

enum CsvStatus { initial, loading, loaded, error }

enum ImportStatus { initial, loading, loaded, error, success }

class ImportTransactionsState extends Equatable {
  const ImportTransactionsState({
    this.csvStatus = CsvStatus.initial,
    this.importStatus = ImportStatus.initial,
    this.csvHeaders = const [],
    this.csvData = const [],
    this.fields = const {},
    this.defaultAccount,
    this.defaultType = TransactionType.invested,
    this.defaultDateFormat,
    this.errorMsg,
    this.transactionsToInsert = const [],
    this.errorInRows = const {},
  });

  final CsvStatus csvStatus;
  final ImportStatus importStatus;
  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  final Map<TransactionField, int?> fields;
  final InveslyAccount? defaultAccount;
  final TransactionType defaultType;
  final String? defaultDateFormat;
  final String? errorMsg;
  final List<InveslyTransaction> transactionsToInsert;
  final Map<int, List<TransactionField>> errorInRows; // { rowNumber : [ Errors ] }

  ImportTransactionsState copyWith({
    CsvStatus? csvStatus,
    ImportStatus? importStatus,
    List<String>? csvHeaders,
    List<List<dynamic>>? csvData,
    Map<TransactionField, int?>? fields,
    InveslyAccount? Function()? defaultAccount,
    TransactionType? defaultType,
    String? defaultDateFormat,
    String? errorMsg,
    List<InveslyTransaction>? transactionsToInsert,
    Map<int, List<TransactionField>>? errorInRows,
  }) {
    return ImportTransactionsState(
      csvStatus: csvStatus ?? this.csvStatus,
      importStatus: importStatus ?? this.importStatus,
      csvHeaders: csvHeaders ?? this.csvHeaders,
      csvData: csvData ?? this.csvData,
      fields: fields ?? this.fields,
      defaultAccount: defaultAccount?.call() ?? this.defaultAccount,
      defaultType: defaultType ?? this.defaultType,
      defaultDateFormat: defaultDateFormat ?? this.defaultDateFormat,
      errorMsg: errorMsg ?? this.errorMsg,
      transactionsToInsert: transactionsToInsert ?? this.transactionsToInsert,
      errorInRows: errorInRows ?? this.errorInRows,
    );
  }

  @override
  List<Object?> get props => [
    csvStatus,
    importStatus,
    csvHeaders,
    csvData,
    fields,
    defaultAccount,
    defaultType,
    defaultDateFormat,
    errorMsg,
    transactionsToInsert,
    errorInRows,
  ];

  @override
  bool? get stringify => true;

  @override
  String toString() {
    return 'csvStatus: $csvStatus, importStatus: $importStatus, csvHeaders: $csvHeaders, csvData: $csvData,'
        ' fields: $fields, defaultAccount: $defaultAccount,'
        ' defaultType: $defaultType, $defaultDateFormat: $defaultDateFormat, errorMsg: $errorMsg'
        ' transactionsToInsert: $transactionsToInsert, errorInRows: $errorInRows';
  }
}

extension ImportTransactionsStateX on ImportTransactionsState {
  bool get isCsvLoading => csvStatus == CsvStatus.loading;
  bool get isCsvLoaded => csvStatus == CsvStatus.loaded;
  bool get isCsvError => csvStatus == CsvStatus.error;

  bool get isImporting => importStatus == ImportStatus.loading;
  bool get isLoaded => importStatus == ImportStatus.loaded;
  bool get isError => importStatus == ImportStatus.error;
}
