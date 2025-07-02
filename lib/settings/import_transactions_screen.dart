import 'dart:io';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';

class ImportTransactionsScreen extends StatefulWidget {
  const ImportTransactionsScreen({super.key});

  @override
  State<ImportTransactionsScreen> createState() => _ImportTransactionsScreenState();
}

const _rowsToPreview = 5;

class _ImportTransactionsScreenState extends State<ImportTransactionsScreen> {
  int currentStep = 0;

  List<List<dynamic>>? csvData;
  Iterable<String>? get csvHeaders => csvData?[0].map((item) => item.toString());

  int? amountColumn;
  int? accountColumn;
  int? dateColumn;
  int? categoryColumn;
  int? notesColumn;
  int? titleColumn;
  final TextEditingController _dateFormatController = TextEditingController(text: 'yyyy-MM-dd HH:mm:ss');

  Future<void> readFile() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;

      final csvString = await File(result.files.single.path!).readAsString();
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
        messenger.showSnackBar(
          const SnackBar(content: Text('All rows in the CSV must have the same number of columns.')),
        );

        return;
      }

      setState(() {
        csvData = parsedCSV;
      });
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  Widget selector({
    required String title,
    String? inputValue,
    // required SupportedIcon? icon,
    Color? iconColor,
    required Function onClick,
    bool isRequired = false,
  }) {
    // icon ??= SupportedIconService.instance.defaultSupportedIcon;
    iconColor ??= Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: TextEditingController(text: inputValue ?? 'Unspecified'),
      readOnly: true,
      // validator: (_) => fieldValidator(inputValue, isRequired: isRequired),
      onTap: () => onClick(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: title,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        prefixIcon: Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          // child: IconDisplayer(mainColor: iconColor, supportedIcon: icon),
        ),
      ),
    );
  }

  DropdownButtonFormField<int> buildColumnSelector({
    required int? value,
    required Iterable<String> headersToSelect,
    String? labelText,
    bool isNullable = true,
    required void Function(int? value) onChanged,
  }) {
    labelText ??= 'Select column';

    return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(labelText: labelText),
      items: [
        if (isNullable) DropdownMenuItem(value: null, child: Text('Unspecified')),
        ...List.generate(
          headersToSelect.length,
          (index) => DropdownMenuItem(
            value: csvHeaders!.toList().indexWhere((element) => element == headersToSelect.toList()[index]),
            child: Text(headersToSelect.toList()[index]),
          ),
        ),
      ],
      onChanged: (value) {
        if (dateColumn == value) dateColumn = null;
        if (notesColumn == value) notesColumn = null;
        if (titleColumn == value) titleColumn = null;
        if (amountColumn == value) amountColumn = null;
        if (accountColumn == value) accountColumn = null;
        if (categoryColumn == value) categoryColumn = null;

        onChanged(value);
      },
    );
  }

  Future<void> addTransactions() async {
    final snackbarDisplayer = ScaffoldMessenger.of(context).showSnackBar;

    onSuccess() {
      // RouteUtils.popAllRoutesExceptFirst();
      // RouteUtils.pushRoute(context, const TabsPage());

      snackbarDisplayer(SnackBar(content: Text('Successfully imported ${csvData!.slice(1).length} transactions.')));
    }

    if (amountColumn == null) {
      snackbarDisplayer(const SnackBar(content: Text('Amount column can not be null')));
      return;
    }

    // final loadingOverlay = LoadingOverlay.of(context);
    // loadingOverlay.show();

    try {
      // final csvRows = csvData!.slice(1).toList();
      // final db = AppDB.instance;
      // const unknownAccountName = 'Account imported';

      // // Cache of known accounts by lowercase name
      // final existingAccounts = {for (final acc in await db.select(db.accounts).get()) acc.name.toLowerCase(): acc};

      // // Cache preferred currency once
      // final preferredCurrency = await CurrencyService.instance.getUserPreferredCurrency().first;

      // final List<TransactionInDB> transactionsToInsert = [];

      // for (final row in csvRows) {
      //   // Resolve account
      //   final accountName = accountColumn == null ? unknownAccountName : row[accountColumn!].toString();
      //   final lowerAccountName = accountName.toLowerCase();

      //   AccountInDB? account = existingAccounts[lowerAccountName];

      //   // If not found, insert and add to cache (unless default is used)
      //   String accountID;
      //   if (account != null) {
      //     accountID = account.id;
      //   } else if (defaultAccount != null) {
      //     accountID = defaultAccount!.id;
      //   } else {
      //     accountID = generateUUID();
      //     account = AccountInDB(
      //       id: accountID,
      //       name: accountName,
      //       iniValue: 0,
      //       displayOrder: 10,
      //       date: DateTime.now(),
      //       type: AccountType.normal,
      //       iconId: SupportedIconService.instance.defaultSupportedIcon.id,
      //       currencyId: preferredCurrency.code,
      //     );
      //     await AccountService.instance.insertAccount(account);
      //     existingAccounts[lowerAccountName] = account;
      //   }

      //   // Resolve category
      //   final categoryToFind = categoryColumn == null ? null : row[categoryColumn!].toString().toLowerCase().trim();

      //   String categoryID;

      //   if (categoryToFind == null) {
      //     categoryID = defaultCategory!.id;
      //   } else {
      //     final category =
      //         (await CategoryService.instance
      //                 .getCategories(
      //                   limit: 1,
      //                   predicate:
      //                       (catTable, pCatTable) =>
      //                           catTable.name.lower().trim().isValue(categoryToFind) |
      //                           pCatTable.name.lower().trim().isValue(categoryToFind),
      //                 )
      //                 .first)
      //             .firstOrNull;
      //     categoryID = category?.id ?? defaultCategory!.id;
      //   }

      //   final trValue = double.parse(row[amountColumn!].toString());

      //   transactionsToInsert.add(
      //     TransactionInDB(
      //       id: generateUUID(),
      //       date:
      //           dateColumn == null
      //               ? DateTime.now()
      //               : DateFormat(_dateFormatController.text, 'en_US').parse(row[dateColumn!].toString()),
      //       type: trValue < 0 ? TransactionType.E : TransactionType.I,
      //       accountID: accountID,
      //       value: trValue,
      //       isHidden: false,
      //       categoryID: categoryID,
      //       notes: notesColumn == null || row[notesColumn!].toString().isEmpty ? null : row[notesColumn!].toString(),
      //       title: titleColumn == null || row[titleColumn!].toString().isEmpty ? null : row[titleColumn!].toString(),
      //     ),
      //   );
      // }

      // // Batch insert
      // const batchSize = 10;

      // for (var i = 0; i < transactionsToInsert.length; i += batchSize) {
      //   final batch = transactionsToInsert.skip(i).take(batchSize);
      //   await Future.wait(batch.map((e) => TransactionService.instance.insertTransaction(e)));
      // }

      // loadingOverlay.hide();
      // onSuccess();
    } catch (e) {
      $logger.e(e);
      // loadingOverlay.hide();
      snackbarDisplayer(SnackBar(content: Text(e.toString())));
    }
  }

  Step buildStep({required int index, required String title, String? description, required List<Widget> content}) {
    return Step(
      title: Text(title),
      isActive: currentStep >= index,
      state:
          currentStep > index
              ? StepState.complete
              : currentStep == index
              ? StepState.editing
              : StepState.disabled,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16.0,
        children: [if (description != null) Text(description, style: context.textTheme.bodySmall), ...content],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual import transactions')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: currentStep,
        onStepTapped: (value) {
          setState(() {
            currentStep = value;
          });
        },
        controlsBuilder: (context, details) {
          final currentStep = details.currentStep;
          bool nextButtonDisabled =
              currentStep == 0 && csvData == null ||
              // currentStep == 3 && defaultCategory == null ||
              currentStep == 3 ||
              currentStep == 1 && amountColumn == null ||
              currentStep == 4 && _dateFormatController.text.isEmpty;

          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child:
                currentStep == 5
                    ? SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: nextButtonDisabled ? null : () => addTransactions(),
                        label: Text('import your data'),
                        icon: const Icon(Icons.check_rounded),
                      ),
                    )
                    : Row(
                      children: [
                        FilledButton(
                          onPressed: nextButtonDisabled ? null : details.onStepContinue,
                          child: Text('Continue'),
                        ),
                        if (currentStep == 0 && csvData != null) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => readFile(),
                            icon: const Icon(Icons.upload_file_rounded),
                            label: Text('Select other file'),
                          ),
                        ],
                        if (currentStep == 2) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                // defaultAccount = null;
                              });
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text('Remove default account'),
                          ),
                        ],
                      ],
                    ),
          );
        },
        onStepContinue: () {
          setState(() => currentStep++);
        },
        steps: [
          buildStep(
            index: 0,
            title: 'Select your file',
            description:
                'Select a .csv file from your device. Make sure it has a first row that describes the name of each column',
            content: [
              if (csvData == null) selectCsvButton(context),
              if (csvData != null) ...[
                csvPreviewTable(context),
                if (csvData!.length - _rowsToPreview >= 1)
                  Text(
                    '+${csvData!.length - _rowsToPreview} rows',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
          buildStep(
            index: 1,
            title: 'Column for quantity',
            description:
                'Select the column where the value of each transaction is specified. Use negative values for expenses and positive values for income. Use a point as a decimal separator',
            content: [
              if (csvHeaders != null)
                buildColumnSelector(
                  value: amountColumn,
                  headersToSelect: csvHeaders!,
                  onChanged: (value) {
                    setState(() {
                      amountColumn = value;
                    });
                  },
                ),
            ],
          ),
          buildStep(
            index: 2,
            title: 'Column for account',
            description:
                'Select the column where the account to which each transaction belongs is specified. You can also select a default account in case we cannot find the account you want. If a default account is not specified, we will create one with the same name ',
            content: [
              if (csvHeaders != null)
                buildColumnSelector(
                  value: accountColumn,
                  headersToSelect: csvHeaders!.whereIndexed((index, element) => index != amountColumn),
                  onChanged: (value) {
                    setState(() {
                      accountColumn = value;
                    });
                  },
                ),
              const SizedBox(height: 12),
              selector(
                title: 'Default account',
                // inputValue: defaultAccount?.name,
                // icon: defaultAccount?.icon,
                iconColor: null,
                onClick: () async {
                  // final modalRes = await showAccountSelectorBottomSheet(
                  //   context,
                  //   AccountSelectorModal(
                  //     allowMultiSelection: false,
                  //     filterSavingAccounts: true,
                  //     selectedAccounts: [if (defaultAccount != null) defaultAccount!],
                  //   ),
                  // );

                  // if (modalRes != null && modalRes.isNotEmpty) {
                  //   setState(() {
                  //     defaultAccount = modalRes.first;
                  //   });
                  // }
                },
              ),
            ],
          ),
          buildStep(
            index: 3,
            title: 'Column for category',
            description:
                'Specify the column where the transaction category name is located. You must specify a default category so that we assign this category to transactions, in case the category cannot be found',
            content: [
              if (csvHeaders != null)
                Builder(
                  builder: (context) {
                    final headersToSelect = csvHeaders!.whereIndexed(
                      (index, element) => index != amountColumn && index != accountColumn,
                    );

                    return buildColumnSelector(
                      value: categoryColumn,
                      headersToSelect: headersToSelect,
                      onChanged: (value) {
                        setState(() {
                          categoryColumn = value;
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 12),
              selector(
                title: 'Default category *',
                // inputValue: defaultCategory?.name,
                // icon: defaultCategory?.icon,
                isRequired: true,
                // iconColor: defaultCategory != null ? ColorHex.get(defaultCategory!.color) : null,
                onClick: () async {
                  // final modalRes = await showCategoryPickerModal(
                  //   context,
                  //   modal: CategoryPicker(selectedCategory: null, categoryType: const [CategoryType.B]),
                  // );

                  // if (modalRes != null) {
                  //   setState(() {
                  //     defaultCategory = modalRes;
                  //   });
                  // }
                },
              ),
            ],
          ),
          buildStep(
            index: 4,
            title: 'Column for date',
            description:
                'Select the column where the date of each transaction is specified. If not specified, transactions will be created with the current date',

            content: [
              if (csvHeaders != null)
                buildColumnSelector(
                  value: dateColumn,
                  headersToSelect: csvHeaders!.whereIndexed(
                    (index, element) =>
                        index != amountColumn &&
                        index != accountColumn &&
                        (categoryColumn == null || index != categoryColumn),
                  ),
                  onChanged: (value) {
                    setState(() {
                      dateColumn = value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateFormatController,
                enabled: dateColumn != null,
                decoration: const InputDecoration(labelText: 'Date format'),
                // validator: (value) => fieldValidator(value),
                autovalidateMode: AutovalidateMode.always,
              ),
            ],
          ),
          buildStep(
            index: 5,
            title: 'other columns',
            description: 'Specifies the columns for other optional transaction attributes',
            content: [
              if (csvHeaders != null)
                Builder(
                  builder: (context) {
                    final headersToSelect = csvHeaders!.whereIndexed(
                      (index, element) =>
                          index != amountColumn &&
                          index != accountColumn &&
                          index != dateColumn &&
                          (categoryColumn == null || index != categoryColumn),
                    );

                    return Column(
                      children: [
                        buildColumnSelector(
                          value: notesColumn,
                          labelText: 'Note column',
                          headersToSelect: headersToSelect,
                          onChanged: (value) {
                            setState(() {
                              notesColumn = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        buildColumnSelector(
                          value: titleColumn,
                          labelText: 'Title column',
                          headersToSelect: headersToSelect,
                          onChanged: (value) {
                            setState(() {
                              titleColumn = value;
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  SingleChildScrollView csvPreviewTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => Theme.of(context).colorScheme.primary.withOpacity(0.18),
        ),
        clipBehavior: Clip.hardEdge,
        headingTextStyle: Theme.of(context).textTheme.labelLarge,
        dataTextStyle: Theme.of(context).textTheme.bodySmall,
        columns: csvHeaders!.map((item) => DataColumn(label: Text(item))).toList(),
        rows: [
          ...csvData!
              .sublist(1, _rowsToPreview > csvData!.length ? null : _rowsToPreview)
              .map((csvrow) => DataRow(cells: csvrow.map((csvItem) => DataCell(Text(csvItem.toString()))).toList())),
        ],
      ),
    );
  }

  InkWell selectCsvButton(BuildContext context) {
    return InkWell(
      onTap: () => readFile(),
      child: Material(
        color: Colors.grey.withAlpha(128),
        shape: RoundedRectangleBorder(side: BorderSide(width: 3.0), borderRadius: BorderRadius.circular(12.0)),
        child: SizedBox(
          height: 150,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 68),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4.0,
              children: [
                Icon(Icons.add, size: 48.0, color: Colors.grey.withAlpha(200)),
                Text('Tap to select file', textAlign: TextAlign.center, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
