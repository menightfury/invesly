import 'dart:io';

import 'package:intl/intl.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common/presentations/widgets/date_format_picker.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

part 'import_transactions_state.dart';

class ImportTransactionsCubit extends Cubit<ImportTransactionsState> {
  ImportTransactionsCubit({
    required AccountRepository accountRepository,
    required AmcRepository amcRepository,
    required TransactionRepository transactionRepository,
  }) : _accountRepository = accountRepository,
       _amcRepository = amcRepository,
       _transactionRepository = transactionRepository,
       super(const ImportTransactionsState());

  final AccountRepository _accountRepository;
  final AmcRepository _amcRepository;
  final TransactionRepository _transactionRepository;

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
          defaultDateFormat: InveslyDateFormatPicker.dateFormats.first,
        ),
      );
    } catch (err) {
      emit(ImportTransactionsState(status: ImportTransactionsStatus.error, errorMsg: err.toString()));
    }
  }

  String? _validateColumnIndex(int? columnIndex) {
    if (columnIndex == null) return null;
    if (columnIndex < 0) {
      return 'Column index cannot be negative.';
    }
    if (columnIndex >= state.csvHeaders.length) {
      return 'Column index exceeds the number of headers.';
    }
    return null;
  }

  void updateField(TransactionField field, int? columnIndex) {
    if (state.status != ImportTransactionsStatus.loaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
      return;
    }

    final fields = Map.of(state.fields);
    if (columnIndex != null) {
      // find out keys (i.e. field names) that has this new value and set those fields to null
      final fieldsAlreadyHasThisIndex = fields.where((_, v) => v == columnIndex).keys;
      if (fieldsAlreadyHasThisIndex.isNotEmpty) {
        for (final i in fieldsAlreadyHasThisIndex) {
          fields[i] = null;
        }
      }
    }
    fields[field] = columnIndex;

    emit(state.copyWith(fields: fields));
    $logger.w(state.fields);
  }

  // void updateAmountColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, amountColumn: columnIndex));
  // }

  // void updateQuantityColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, quantityColumn: columnIndex));
  // }

  // void updateAccountColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, accountColumn: columnIndex));
  // }

  // void updateAmcColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, amcColumn: columnIndex));
  // }

  // void updateTypeColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, typeColumn: columnIndex));
  // }

  // void updateDateColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, dateColumn: columnIndex));
  // }

  // void updateNotesColumn(int columnIndex) {
  //   if (state.status != ImportTransactionsStatus.loaded) return;

  //   final err = _validateColumnIndex(columnIndex);
  //   if (err != null) {
  //     emit(state.copyWith(status: ImportTransactionsStatus.error, errorMsg: err));
  //     return;
  //   }

  //   emit(state.copyWith(status: ImportTransactionsStatus.loaded, notesColumn: columnIndex));
  // }

  void updateDefaultAccount(InveslyAccount? account) {
    if (state.status != ImportTransactionsStatus.loaded) return;
    if (account == null) {
      // emit(state.copyWith(defaultAccount: InveslyAccount.empty()));
      emit(state.copyWith(defaultAccount: () => null));
      return;
    }
    emit(state.copyWith(defaultAccount: () => account));
  }

  void updateDefaultType(TransactionType? type) {
    if (state.status != ImportTransactionsStatus.loaded) return;
    if (type == null) {
      emit(state.copyWith(defaultType: TransactionType.invested));
      return;
    }

    emit(state.copyWith(defaultType: type));
  }

  void updateDefaultDateFormat(String? dateFormat) {
    if (state.status != ImportTransactionsStatus.loaded) return;
    if (dateFormat == null) {
      emit(state.copyWith(defaultDateFormat: InveslyDateFormatPicker.dateFormats.first));
      return;
    }

    emit(state.copyWith(defaultDateFormat: dateFormat));
  }

  Future<void> importTransactions() async {
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

    // final loadingOverlay = LoadingOverlay.of(context);
    // loadingOverlay.show();

    try {
      // final csvRows = state.csvData.slice(1).toList();
      final csvRows = state.csvData;
      final db = AppDB.instance;
      const unknownAccountName = 'Account imported';

      // Cache of known accounts by lowercase name
      final existingAccounts = {for (final acc in await db.select(db.accounts).get()) acc.name.toLowerCase(): acc};

      // Cache preferred currency once
      final preferredCurrency = await CurrencyService.instance.getUserPreferredCurrency().first;

      final List<TransactionInDb> transactionsToInsert = [];

      for (final row in csvRows) {
        // Resolve account
        final accountName = accountColumn == null ? unknownAccountName : row[accountColumn!].toString();
        final lowerAccountName = accountName.toLowerCase();

        AccountInDb? account = existingAccounts[lowerAccountName];

        // If not found, insert and add to cache (unless default is used)
        String accountID;
        if (account != null) {
          accountID = account.id;
        } else if (defaultAccount != null) {
          accountID = defaultAccount!.id;
        } else {
          accountID = $uuid.v1();
          account = AccountInDb(
            id: accountID,
            name: accountName,
            avatarIndex: 0,
            iniValue: 0,
            displayOrder: 10,
            date: DateTime.now(),
            type: AccountType.normal,
            iconId: SupportedIconService.instance.defaultSupportedIcon.id,
            currencyId: preferredCurrency.code,
          );
          await AccountService.instance.insertAccount(account);
          existingAccounts[lowerAccountName] = account;
        }

        // Resolve category
        final amcColumnIndex = state.fields[TransactionField.amc];
        final amcToFind = amcColumnIndex == null
            ? null
            : row[amcColumnIndex].toString().trim().toLowerCase(); // it will be either amc id or amc name

        String? amcId;

        final amc =
            (await _amcRepository
                    .getCategories(
                      limit: 1,
                      predicate: (catTable, pCatTable) =>
                          catTable.name.lower().trim().isValue(amcToFind) |
                          pCatTable.name.lower().trim().isValue(amcToFind),
                    )
                    .first)
                .firstOrNull;
        amcId = amc?.id;

        final rawTotalAmount = row[state.fields[TransactionField.amount]!];
        final totalAmount = double.tryParse(rawAmount.toString());

        final dateNow = DateTime.now();
        late final DateTime date;
        if (state.fields[TransactionField.date] != null && state.defaultDateFormat != null) {
          final rawDate = row[state.fields[TransactionField.date]!];
          date = DateFormat(state.defaultDateFormat, 'en_IN').tryParse(rawDate.toString()) ?? dateNow;
        } else {
          date = dateNow;
        }
        transactionsToInsert.add(
          TransactionInDb(
            id: $uuid.v1(),
            date: date.millisecondsSinceEpoch,
            typeIndex: totalAmount < 0 ? TransactionType.E : TransactionType.I,
            accountId: accountID,
            totalAmount: totalAmount,
            amcId: amcId,
            notes: notesColumn == null || row[notesColumn!].toString().isEmpty ? null : row[notesColumn!].toString(),
          ),
        );
      }

      // Batch insert
      const batchSize = 10;

      for (var i = 0; i < transactionsToInsert.length; i += batchSize) {
        final batch = transactionsToInsert.skip(i).take(batchSize);
        await Future.wait(batch.map((e) => TransactionService.instance.insertTransaction(e)));
      }

      // loadingOverlay.hide();
      // onSuccess();
    } catch (e) {
      $logger.e(e);
      // loadingOverlay.hide();
      // snackbarDisplayer(SnackBar(content: Text(e.toString())));
    }
  }
}
