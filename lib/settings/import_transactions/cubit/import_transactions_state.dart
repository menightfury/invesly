part of 'import_transactions_cubit.dart';

enum TransactionField { amount, quantity, account, amc, type, date, notes }

enum ImportTransactionsStatus { initial, loading, loaded, error }

class ImportTransactionsState extends Equatable {
  const ImportTransactionsState({
    this.status = ImportTransactionsStatus.initial,
    this.csvHeaders = const [],
    this.csvData = const [],
    this.fields = const {},
    this.defaultAccount,
    this.defaultType = TransactionType.invested,
    this.defaultDateFormat,
    this.errorMsg,
  });

  final ImportTransactionsStatus status;
  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  final Map<TransactionField, int?> fields;
  final InveslyAccount? defaultAccount;
  final TransactionType defaultType;
  final String? defaultDateFormat;
  final String? errorMsg;

  ImportTransactionsState copyWith({
    ImportTransactionsStatus? status,
    List<String>? csvHeaders,
    List<List<dynamic>>? csvData,
    Map<TransactionField, int?>? fields,
    InveslyAccount? Function()? defaultAccount,
    TransactionType? defaultType,
    String? defaultDateFormat,
    String? errorMsg,
  }) {
    return ImportTransactionsState(
      status: status ?? this.status,
      csvHeaders: csvHeaders ?? this.csvHeaders,
      csvData: csvData ?? this.csvData,
      fields: fields ?? this.fields,
      // defaultAccount: defaultAccount ?? this.defaultAccount,
      defaultAccount: defaultAccount?.call() ?? this.defaultAccount,
      defaultType: defaultType ?? this.defaultType,
      defaultDateFormat: defaultDateFormat ?? this.defaultDateFormat,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  List<Object?> get props => [csvHeaders, csvData, fields, defaultAccount, defaultType, defaultDateFormat, errorMsg];

  @override
  bool? get stringify => true;
}

extension ImportTransactionsStateX on ImportTransactionsState {
  bool get isLoading => status == ImportTransactionsStatus.initial || status == ImportTransactionsStatus.loading;
  bool get isLoaded => status == ImportTransactionsStatus.loaded;
  bool get isError => status == ImportTransactionsStatus.error;
}
