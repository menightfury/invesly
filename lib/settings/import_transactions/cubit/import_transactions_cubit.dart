import 'dart:io';

import 'package:intl/intl.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/amcs/model/amc_model.dart';
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
      emit(const ImportTransactionsState(csvStatus: CsvStatus.error, errorMsg: 'No file selected'));
      return;
    }

    emit(const ImportTransactionsState(csvStatus: CsvStatus.loading));

    await Future.delayed(2.seconds); // ! TODO: remove this line

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
            csvStatus: CsvStatus.error,
            errorMsg: 'All rows in the CSV must have the same number of columns.',
          ),
        );
        return;
      }

      emit(
        ImportTransactionsState(
          csvStatus: CsvStatus.loaded,
          csvHeaders: parsedCSV.first.map((e) => e.toString()).toList(),
          csvData: parsedCSV.sublist(1),
          defaultDateFormat: InveslyDateFormatPicker.dateFormats.first,
        ),
      );
    } catch (err) {
      emit(ImportTransactionsState(csvStatus: CsvStatus.error, errorMsg: err.toString()));
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
    if (!state.isCsvLoaded) return;

    final err = _validateColumnIndex(columnIndex);
    if (err != null) {
      emit(state.copyWith(csvStatus: CsvStatus.error, errorMsg: err));
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

  void updateDefaultAccount(InveslyAccount? account) {
    if (!state.isCsvLoaded) return;
    if (account == null) {
      // emit(state.copyWith(defaultAccount: InveslyAccount.empty()));
      emit(state.copyWith(defaultAccount: () => null));
      return;
    }
    emit(state.copyWith(defaultAccount: () => account));
  }

  void updateDefaultType(TransactionType? type) {
    if (!state.isCsvLoaded) return;
    if (type == null) {
      emit(state.copyWith(defaultType: TransactionType.invested));
      return;
    }

    emit(state.copyWith(defaultType: type));
  }

  void updateDefaultDateFormat(String? dateFormat) {
    if (!state.isCsvLoaded) return;
    if (dateFormat == null) {
      emit(state.copyWith(defaultDateFormat: InveslyDateFormatPicker.dateFormats.first));
      return;
    }

    emit(state.copyWith(defaultDateFormat: dateFormat));
  }

  Future<void> reviewTransactions() async {
    emit(state.copyWith(importStatus: ImportStatus.loading));

    final csvRows = state.csvData;
    final dateNow = DateTime.now();
    final amountColumnIndex = state.fields[TransactionField.amount];
    final qntyColumnIndex = state.fields[TransactionField.quantity];
    final accountColumnIndex = state.fields[TransactionField.account];
    final amcColumnIndex = state.fields[TransactionField.amc];
    final typeColumnIndex = state.fields[TransactionField.amount];
    final dateColumnIndex = state.fields[TransactionField.date];
    final noteColumnIndex = state.fields[TransactionField.notes];

    // Cache of accounts and amcs
    final existingAccounts = <String, InveslyAccount>{};
    final existingAmcs = <String, InveslyAmc>{};

    final transactionsToInsert = <InveslyTransaction>[];
    final errors = <int, List<TransactionField>>{}; // { rowNumber : [ Errors ] }

    for (var i = 0; i < csvRows.length; i++) {
      final row = csvRows[i];
      // Resolve type
      // The type can be integer (i.e. 0 for investment and 1 for redemption, 2 for dividend) or
      // can be one character (like I, R, D) or can be string (Investment, Redemption or Dividend)
      TransactionType? type = state.defaultType;
      final rawType = typeColumnIndex == null ? null : row[typeColumnIndex];
      if (rawType is int) {
        type = TransactionType.fromInt(rawType);
      } else if (rawType is String) {
        type = rawType.length == 1 ? TransactionType.fromChar(rawType) : TransactionType.fromString(rawType);
      }

      // Resolve amount
      final totalAmount = amountColumnIndex == null ? null : double.tryParse(row[amountColumnIndex].toString());
      if (totalAmount == null) {
        errors[i] = [...?errors[i], TransactionField.amount];
      }

      // Resolve quantity
      final quantity = qntyColumnIndex == null ? null : double.tryParse(row[qntyColumnIndex].toString());

      // Resolve account
      // distinguish between accountIdOrName = null and account = null
      // (i.e. accountIdOrName is provided but account not exists)
      final accountIdOrName = accountColumnIndex == null
          ? null
          : row[accountColumnIndex].toString().trim().toLowerCase();
      InveslyAccount? account = state.defaultAccount;
      if (accountIdOrName != null && accountIdOrName.isNotEmpty) {
        // Look for account in cache first
        if (existingAccounts.containsKey(accountIdOrName)) {
          account = existingAccounts[accountIdOrName];
        } else {
          // Look for account in database
          final account_ = await _accountRepository.getAccount(accountIdOrName);
          if (account_ == null) {
            // accountIdOrName is provided but account not exists
            // show modal to select one of the accounts or to add a new account with that name
            errors[i] = [...?errors[i], TransactionField.account];
            account = InveslyAccount.empty(id: accountIdOrName, name: accountIdOrName);
          } else {
            // add fetched account to `existingAccounts` cache for future
            existingAccounts[account_.id] = account_;
            account = account_;
          }
        }
      }

      // Resolve amc
      final amcIdOrName = amcColumnIndex == null ? null : row[amcColumnIndex].toString().trim();
      InveslyAmc? amc;
      if (amcIdOrName != null && amcIdOrName.isNotEmpty) {
        // Look for amc in cache first
        if (existingAmcs.containsKey(amcIdOrName)) {
          amc = existingAmcs[amcIdOrName];
        } else {
          // Look for amc in database
          final amc_ = await _amcRepository.getAmc(amcIdOrName);
          if (amc_ == null) {
            // amcIdOrName is provided but amc not exists
            // show modal to select one of the amcs or to add a new amc with that name
            errors[i] = [...?errors[i], TransactionField.amc];
          } else {
            // add fetched amc to `existingAmcs` cache for future
            existingAmcs[amc_.id] = amc_;
            amc = amc_;
          }
        }
      }

      // Resolve date
      late final DateTime date;
      if (dateColumnIndex != null && state.defaultDateFormat != null) {
        date = DateFormat(state.defaultDateFormat).tryParse(row[dateColumnIndex].toString()) ?? dateNow;
      } else {
        date = dateNow;
      }

      // Resolve note
      final note = noteColumnIndex == null ? null : row[noteColumnIndex].toString();

      transactionsToInsert.add(
        InveslyTransaction(
          id: $uuid.v1(),
          account: account ?? InveslyAccount.empty(),
          investedOn: date,
          quantity: quantity ?? 0.0,
          totalAmount: totalAmount ?? 0.0,
          amc: amc,
          note: (note?.isEmpty ?? true) ? null : note,
        ),
      );
    } // end of for loop

    emit(
      state.copyWith(
        importStatus: errors.isEmpty ? ImportStatus.loaded : ImportStatus.error,
        transactionsToInsert: transactionsToInsert,
        errorInRows: errors,
      ),
    );
  }

  Future<void> importTransactions() async {
    // if (errors[i]?.isEmpty ?? true) {
    // transactionsToInsert.add(
    //   TransactionInDb(
    //     id: $uuid.v1(),
    //     accountId: accountId!,
    //     date: date.millisecondsSinceEpoch,
    //     quantity: quantity ?? 0.0,
    //     totalAmount: totalAmount ?? 0.0,
    //     amcId: amcId,
    //     note: (note?.isEmpty ?? true) ? null : note,
    //   ),
    // );
    // }
    try {
      // await _transactionRepository.insertTransactions(transactionsToInsert);
      $logger.d(state.transactionsToInsert);
      emit(state.copyWith(importStatus: ImportStatus.success));
    } catch (e) {
      $logger.e(e);
      emit(state.copyWith(importStatus: ImportStatus.error));
    }
  }
}
