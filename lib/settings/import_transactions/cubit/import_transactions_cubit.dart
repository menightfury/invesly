import 'dart:io';

import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';
import 'package:invesly/transactions/model/transaction_model.dart';

part 'import_transactions_state.dart';

class ImportTransactionsCubit extends Cubit<ImportTransactionsState> {
  ImportTransactionsCubit() : super(ImportTransactionsState());

  void readFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result == null || result.files.isEmpty) {
      emit(const ImportTransactionsState(status: ImportTransactionsStatus.error, errorMsg: 'No file selected'));
      return;
    }

    emit(const ImportTransactionsState(status: ImportTransactionsStatus.loading));

    await Future.delayed(3.seconds); // ! TODO: remove this line

    try {
      final csvString = await File(result.files.first.path!).readAsString();
      final parsedCSV = BackupRestoreRepository.processCsv(csvString);

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
        emit(
          ImportTransactionsState(
            status: ImportTransactionsStatus.error,
            errorMsg: 'All rows in the CSV must have the same number of columns.',
          ),
        );
        return;
      }

      emit(
        ImportTransactionsState(
          status: ImportTransactionsStatus.loaded,
          csvHeaders: parsedCSV.first.map((e) => e.toString()).toList(),
          csvData: parsedCSV.sublist(1),
        ),
      );
    } catch (err) {
      emit(ImportTransactionsState(status: ImportTransactionsStatus.error, errorMsg: err.toString()));
    }
  }

  String? _validateColumnIndex(int columnIndex) {
    if (columnIndex < 0) {
      return 'Column index cannot be negative.';
    }
    if (columnIndex >= state.csvHeaders.length) {
      return 'Column index exceeds the number of headers.';
    }
    return null;
  }

  // void updateColumn(CsvColumn column, int? value) {
  // if (state.status != ImportTransactionsStatus.loaded) return;

  // final err = _validateColumnIndex(columnIndex);
  // if (err != null) {
  //   emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //   return;
  // }

  //   final columns = Map.of(st.columns);
  //   if (value != null) {
  //     // find out keys (i.e. column names) that has this new value and set those column values to null
  //     final keysAlreadyHasThisValue = columns.where((_, v) => v == value).keys;
  //     if (keysAlreadyHasThisValue.isNotEmpty) {
  //       for (final key in keysAlreadyHasThisValue) {
  //         columns[key] = null;
  //       }
  //     }
  //   }
  //   columns[column] = value;
  //   $logger.i(columns);
  //   emit(state.copyWith(columns: columns));
  // }

  void updateAmountColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, amountColumn: columnIndex));
  }

  void updateQuantityColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, quantityColumn: columnIndex));
  }

  void updateAccountColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, accountColumn: columnIndex));
  }

  void updateTypeColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, typeColumn: columnIndex));
  }

  void updateDateColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, dateColumn: columnIndex));
  }

  void updateNotesColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, notesColumn: columnIndex));
  }

  void updateTitleColumn(int columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    emit(state.copyWith(status: ImportTransactionsStatus.loaded, titleColumn: columnIndex));
  }

  void updateDefaultAccount(InveslyAccount account) {
    if (state.status != ImportTransactionsStatus.loaded) return;
    emit(state.copyWith(defaultAccount: account));
  }

  void updateDefaultType(TransactionType type) {
    if (state.status != ImportTransactionsStatus.loaded) return;
    emit(state.copyWith(defaultType: type));
  }

  void updateDefaultDateFormat(String dateFormat) {
    if (state.status != ImportTransactionsStatus.loaded) return;
    emit(state.copyWith(defaultDateFormat: dateFormat));
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
