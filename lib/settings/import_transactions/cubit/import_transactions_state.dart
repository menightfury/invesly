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
    this.errorMsg,
  });

  final ImportTransactionsStatus status;
  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  // final Map<CsvColumn, int?> columns;
  final int? amountColumn, accountColumn, dateColumn, categoryColumn, notesColumn, titleColumn;
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
    errorMsg,
  ];

  @override
  bool? get stringify => true;
}

// final class ImportTransactionsInitialState extends ImportTransactionsState {
//   const ImportTransactionsInitialState();
// }

// final class ImportTransactionsLoadingState extends ImportTransactionsState {
//   const ImportTransactionsLoadingState();
// }

// final class ImportTransactionsLoadedState extends ImportTransactionsState {
//   const ImportTransactionsLoadedState({
//     required this.csvHeaders,
//     required this.csvData,
//     // this.columns = const {},
//     this.amountColumn,
//     this.accountColumn,
//     this.dateColumn,
//     this.categoryColumn,
//     this.notesColumn,
//     this.titleColumn,
//   });

//   final List<String> csvHeaders;
//   final List<List<dynamic>> csvData;
//   // final Map<CsvColumn, int?> columns;
//   final int? amountColumn, accountColumn, dateColumn, categoryColumn, notesColumn, titleColumn;

//   ImportTransactionsLoadedState copyWith({
//     List<String>? csvHeaders,
//     List<List<dynamic>>? csvData,
//     int? amountColumn,
//     int? accountColumn,
//     int? dateColumn,
//     int? categoryColumn,
//     int? notesColumn,
//     int? titleColumn,
//   }) {
//     return ImportTransactionsLoadedState(
//       csvHeaders: csvHeaders ?? this.csvHeaders,
//       csvData: csvData ?? this.csvData,
//       amountColumn: amountColumn ?? this.amountColumn,
//       accountColumn: accountColumn ?? this.accountColumn,
//       dateColumn: dateColumn ?? this.dateColumn,
//       categoryColumn: categoryColumn ?? this.categoryColumn,
//       notesColumn: notesColumn ?? this.notesColumn,
//       titleColumn: titleColumn ?? this.titleColumn,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     csvHeaders,
//     csvData,
//     amountColumn,
//     accountColumn,
//     dateColumn,
//     categoryColumn,
//     notesColumn,
//     titleColumn,
//   ];
// }

// final class ImportTransactionsErrorState extends ImportTransactionsState {
//   const ImportTransactionsErrorState(this.errorMsg);

//   final String errorMsg;

//   @override
//   List<Object> get props => [errorMsg];
// }

// extension ImportTransactionsStateX on ImportTransactionsState {
//   bool get isLoading => this is ImportTransactionsInitialState || this is ImportTransactionsLoadingState;
//   bool get isLoaded => this is ImportTransactionsLoadedState;
//   bool get isError => this is ImportTransactionsErrorState;
// }
