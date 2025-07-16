import 'dart:io';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';

part 'import_transactions_state.dart';

class ImportTransactionsCubit extends Cubit<ImportTransactionsState> {
  ImportTransactionsCubit() : super(ImportTransactionsInitialState());

  void readFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null || result.files.isEmpty) {
      emit(const ImportTransactionsErrorState('No file selected'));

      return;
    }

    emit(const ImportTransactionsLoadingState());

    // ! testing // TODO: remove this line
    await Future.delayed(3.seconds);

    try {
      final csvString = await File(result.files.first.path!).readAsString();
      final parsedCSV = BackupDatabaseService.processCsv(csvString);

      final firstRowLength = parsedCSV.first.length;

      if (parsedCSV.length >= 2 && firstRowLength == parsedCSV[1].length + 1) {
        // Remove trailing column in header row if it has one more than the second row
        parsedCSV[0].removeLast();
      }

      if (parsedCSV.length > 2 && parsedCSV.last.every((cell) => cell.trim().isEmpty)) {
        // Remove last row if it's effectively empty
        parsedCSV.removeLast();
      }

      final allRowsSameLength = parsedCSV.every((row) => row.length == firstRowLength);

      if (!allRowsSameLength) {
        emit(ImportTransactionsErrorState('All rows in the CSV must have the same number of columns.'));
        return;
      }

      emit(
        ImportTransactionsLoadedState(
          csvHeaders: parsedCSV.first.map((e) => e.toString()).toList(),
          csvData: parsedCSV.sublist(1),
        ),
      );
    } catch (err) {
      emit(ImportTransactionsErrorState(err.toString()));
    }
  }

  void updateColumn(CsvColumn column, int? value) {
    if (state is! ImportTransactionsLoadedState) return;
    final st = state as ImportTransactionsLoadedState;

    if (value != null && value < 0) {
      emit(ImportTransactionsErrorState('Column index cannot be negative.'));
      return;
    }
    if (value != null && value >= st.csvHeaders.length) {
      emit(ImportTransactionsErrorState('Column index exceeds the number of headers.'));
      return;
    }

    final columns = Map.of(st.columns);
    if (value != null) {
      // find out keys (i.e. column names) that has this new value and set those column values to null
      final keysAlreadyHasThisValue = columns.where((_, v) => v == value).keys;
      if (keysAlreadyHasThisValue.isNotEmpty) {
        for (final key in keysAlreadyHasThisValue) {
          columns[key] = null;
        }
      }
    }
    columns[column] = value;
    $logger.i(columns);
    emit(st.copyWith(columns: columns));
  }

  Future<void> addTransactions() async {
    // final snackbarDisplayer = ScaffoldMessenger.of(context).showSnackBar;

    // onSuccess() {
    //   // RouteUtils.popAllRoutesExceptFirst();
    //   // RouteUtils.pushRoute(context, const TabsPage());

    //   snackbarDisplayer(SnackBar(content: Text('Successfully imported ${csvData!.slice(1).length} transactions.')));
    // }

    // if (amountColumn == null) {
    //   snackbarDisplayer(const SnackBar(content: Text('Amount column can not be null')));
    //   return;
    // }

    // // final loadingOverlay = LoadingOverlay.of(context);
    // // loadingOverlay.show();

    // try {
    //   // final csvRows = csvData!.slice(1).toList();
    //   // final db = AppDB.instance;
    //   // const unknownAccountName = 'Account imported';

    //   // // Cache of known accounts by lowercase name
    //   // final existingAccounts = {for (final acc in await db.select(db.accounts).get()) acc.name.toLowerCase(): acc};

    //   // // Cache preferred currency once
    //   // final preferredCurrency = await CurrencyService.instance.getUserPreferredCurrency().first;

    //   // final List<TransactionInDB> transactionsToInsert = [];

    //   // for (final row in csvRows) {
    //   //   // Resolve account
    //   //   final accountName = accountColumn == null ? unknownAccountName : row[accountColumn!].toString();
    //   //   final lowerAccountName = accountName.toLowerCase();

    //   //   AccountInDB? account = existingAccounts[lowerAccountName];

    //   //   // If not found, insert and add to cache (unless default is used)
    //   //   String accountID;
    //   //   if (account != null) {
    //   //     accountID = account.id;
    //   //   } else if (defaultAccount != null) {
    //   //     accountID = defaultAccount!.id;
    //   //   } else {
    //   //     accountID = generateUUID();
    //   //     account = AccountInDB(
    //   //       id: accountID,
    //   //       name: accountName,
    //   //       iniValue: 0,
    //   //       displayOrder: 10,
    //   //       date: DateTime.now(),
    //   //       type: AccountType.normal,
    //   //       iconId: SupportedIconService.instance.defaultSupportedIcon.id,
    //   //       currencyId: preferredCurrency.code,
    //   //     );
    //   //     await AccountService.instance.insertAccount(account);
    //   //     existingAccounts[lowerAccountName] = account;
    //   //   }

    //   //   // Resolve category
    //   //   final categoryToFind = categoryColumn == null ? null : row[categoryColumn!].toString().toLowerCase().trim();

    //   //   String categoryID;

    //   //   if (categoryToFind == null) {
    //   //     categoryID = defaultCategory!.id;
    //   //   } else {
    //   //     final category =
    //   //         (await CategoryService.instance
    //   //                 .getCategories(
    //   //                   limit: 1,
    //   //                   predicate:
    //   //                       (catTable, pCatTable) =>
    //   //                           catTable.name.lower().trim().isValue(categoryToFind) |
    //   //                           pCatTable.name.lower().trim().isValue(categoryToFind),
    //   //                 )
    //   //                 .first)
    //   //             .firstOrNull;
    //   //     categoryID = category?.id ?? defaultCategory!.id;
    //   //   }

    //   //   final trValue = double.parse(row[amountColumn!].toString());

    //   //   transactionsToInsert.add(
    //   //     TransactionInDB(
    //   //       id: generateUUID(),
    //   //       date:
    //   //           dateColumn == null
    //   //               ? DateTime.now()
    //   //               : DateFormat(_dateFormatController.text, 'en_US').parse(row[dateColumn!].toString()),
    //   //       type: trValue < 0 ? TransactionType.E : TransactionType.I,
    //   //       accountID: accountID,
    //   //       value: trValue,
    //   //       isHidden: false,
    //   //       categoryID: categoryID,
    //   //       notes: notesColumn == null || row[notesColumn!].toString().isEmpty ? null : row[notesColumn!].toString(),
    //   //       title: titleColumn == null || row[titleColumn!].toString().isEmpty ? null : row[titleColumn!].toString(),
    //   //     ),
    //   //   );
    //   // }

    //   // // Batch insert
    //   // const batchSize = 10;

    //   // for (var i = 0; i < transactionsToInsert.length; i += batchSize) {
    //   //   final batch = transactionsToInsert.skip(i).take(batchSize);
    //   //   await Future.wait(batch.map((e) => TransactionService.instance.insertTransaction(e)));
    //   // }

    //   // loadingOverlay.hide();
    //   // onSuccess();
    // } catch (e) {
    //   $logger.e(e);
    //   // loadingOverlay.hide();
    //   snackbarDisplayer(SnackBar(content: Text(e.toString())));
    // }
  }
}
