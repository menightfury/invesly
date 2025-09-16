part of 'import_transactions_cubit.dart';

enum CsvColumn { amount, account, date, category, notes, title }

sealed class ImportTransactionsState extends Equatable {
  const ImportTransactionsState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => true;
}

final class ImportTransactionsInitialState extends ImportTransactionsState {
  const ImportTransactionsInitialState();
}

final class ImportTransactionsLoadingState extends ImportTransactionsState {
  const ImportTransactionsLoadingState();
}

final class ImportTransactionsLoadedState extends ImportTransactionsState {
  const ImportTransactionsLoadedState({required this.csvHeaders, required this.csvData, this.columns = const {}});

  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  final Map<CsvColumn, int?> columns;

  ImportTransactionsLoadedState copyWith({
    List<List<dynamic>>? csvData,
    List<String>? csvHeaders,
    Map<CsvColumn, int?>? columns,
  }) {
    return ImportTransactionsLoadedState(
      csvHeaders: csvHeaders ?? this.csvHeaders,
      csvData: csvData ?? this.csvData,
      columns: columns ?? this.columns,
    );
  }

  @override
  List<Object?> get props => [csvHeaders, csvData, columns];
}

final class ImportTransactionsErrorState extends ImportTransactionsState {
  const ImportTransactionsErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object> get props => [errorMsg];
}

extension ImportTransactionsStateX on ImportTransactionsState {
  bool get isLoading => this is ImportTransactionsInitialState || this is ImportTransactionsLoadingState;
  bool get isLoaded => this is ImportTransactionsLoadedState;
  bool get isError => this is ImportTransactionsErrorState;
}
