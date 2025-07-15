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
  const ImportTransactionsLoadedState({
    required this.csvHeaders,
    required this.csvData,
    this.columns = const {},
    // this.amountColumn,
    // this.accountColumn,
    // this.dateColumn,
    // this.categoryColumn,
    // this.notesColumn,
    // this.titleColumn,
  });

  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  final Map<CsvColumn, int?> columns;
  // final int? amountColumn;
  // final int? accountColumn;
  // final int? dateColumn;
  // final int? categoryColumn;
  // final int? notesColumn;
  // final int? titleColumn;

  // Iterable<int?> otherColumnValues(CsvColumn column) {
  //   return columns.entries.whereNot((e) => e.key == column).map((e) => e.value);
  // }

  ImportTransactionsLoadedState copyWith({
    List<List<dynamic>>? csvData,
    List<String>? csvHeaders,
    Map<CsvColumn, int?>? columns,
    // int? amountColumn,
    // int? accountColumn,
    // int? dateColumn,
    // int? categoryColumn,
    // int? notesColumn,
    // int? titleColumn,
  }) {
    return ImportTransactionsLoadedState(
      csvHeaders: csvHeaders ?? this.csvHeaders,
      csvData: csvData ?? this.csvData,
      columns: columns ?? this.columns,
      // amountColumn: amountColumn ?? this.amountColumn,
      // accountColumn: accountColumn ?? this.accountColumn,
      // dateColumn: dateColumn ?? this.dateColumn,
      // categoryColumn: categoryColumn ?? this.categoryColumn,
      // notesColumn: notesColumn ?? this.notesColumn,
      // titleColumn: titleColumn ?? this.titleColumn,
    );
  }

  @override
  List<Object?> get props => [csvHeaders, csvData, columns];
  // List<Object?> get props => [
  //   csvHeaders,
  //   csvData,
  //   amountColumn,
  //   accountColumn,
  //   dateColumn,
  //   categoryColumn,
  //   notesColumn,
  //   titleColumn,
  // ];
}

final class ImportTransactionsErrorState extends ImportTransactionsState {
  const ImportTransactionsErrorState(this.errorMsg);

  final String errorMsg;

  @override
  List<Object> get props => [errorMsg];
}
