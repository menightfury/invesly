part of 'import_transactions_cubit.dart';

sealed class ImportTransactionsState extends Equatable {
  const ImportTransactionsState();

  @override
  List<Object> get props => [];
}

final class ImportTransactionsInitialState extends ImportTransactionsState {
  const ImportTransactionsInitialState();
}

final class ImportTransactionsLoadingState extends ImportTransactionsState {
  const ImportTransactionsLoadingState();
}

final class ImportTransactionsLoadedState extends ImportTransactionsState {
  const ImportTransactionsLoadedState(this.csvHeaders, this.csvData);

  final List<List<dynamic>> csvData;
  final List<String> csvHeaders;
  // Iterable<String>? get csvHeaders => csvData[0].map((item) => item.toString());

  // int? amountColumn;
  // int? accountColumn;
  // int? dateColumn;
  // int? categoryColumn;
  // int? notesColumn;
  // int? titleColumn;
}

final class ImportTransactionsErrorState extends ImportTransactionsState {
  const ImportTransactionsErrorState(this.errorMsg);

  final String errorMsg;
}
