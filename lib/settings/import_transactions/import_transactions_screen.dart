import 'dart:io';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';
import 'package:invesly/settings/import_transactions/cubit/import_transactions_cubit.dart';

class ImportTransactionsScreen extends StatelessWidget {
  const ImportTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual import transactions')),
      body: SafeArea(
        child: BlocProvider(create: (context) => ImportTransactionsCubit(), child: _ImportTransactionsScreen()),
      ),
    );
  }
}

class _ImportTransactionsScreen extends StatefulWidget {
  const _ImportTransactionsScreen({super.key});

  @override
  State<_ImportTransactionsScreen> createState() => __ImportTransactionsScreenState();
}

class __ImportTransactionsScreenState extends State<_ImportTransactionsScreen> {
  int currentStep = 0;

  int? amountColumn;
  int? accountColumn;
  int? dateColumn;
  int? categoryColumn;
  int? notesColumn;
  int? titleColumn;
  final TextEditingController _dateFormatController = TextEditingController(text: 'yyyy-MM-dd HH:mm:ss');

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
    return Stepper(
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
          padding: const EdgeInsets.only(top: 12.0),
          child:
              currentStep == 5
                  ? SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          nextButtonDisabled ? null : () => context.read<ImportTransactionsCubit>().addTransactions(),
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
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                if (state is ImportTransactionsLoadedState) {
                  return _CsvPreviewTable(state.csvHeaders, state.csvData);
                }

                return _SelectCsvButton();
              },
            ),
          ],
        ),
        buildStep(
          index: 1,
          title: 'Column for quantity',
          description:
              'Select the column where the value of each transaction is specified. Use negative values for expenses and positive values for income. Use a point as a decimal separator',
          content: [
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                if (state is ImportTransactionsLoadedState) {
                  return Column(
                    children: <Widget>[
                      _ColumnSelector(
                        value: amountColumn,
                        columns: state.csvHeaders,
                        onChanged: (value) {
                          setState(() {
                            amountColumn = value;
                          });
                        },
                      ),
                      _ColumnSelector(
                        value: accountColumn,
                        columns: state.csvHeaders.whereIndexed((index, element) => index != amountColumn),
                        onChanged: (value) {
                          setState(() {
                            accountColumn = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _Selector(
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

                      Builder(
                        builder: (context) {
                          final headersToSelect = state.csvHeaders.whereIndexed(
                            (index, element) => index != amountColumn && index != accountColumn,
                          );

                          return _ColumnSelector(
                            value: categoryColumn,
                            columns: headersToSelect,
                            onChanged: (value) {
                              setState(() {
                                categoryColumn = value;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _Selector(
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

                      _ColumnSelector(
                        value: dateColumn,
                        columns: state.csvHeaders.whereIndexed(
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

                      Builder(
                        builder: (context) {
                          final headersToSelect = state.csvHeaders.whereIndexed(
                            (index, element) =>
                                index != amountColumn &&
                                index != accountColumn &&
                                index != dateColumn &&
                                (categoryColumn == null || index != categoryColumn),
                          );

                          return Column(
                            children: [
                              _ColumnSelector(
                                value: notesColumn,
                                labelText: 'Note column',
                                columns: headersToSelect,
                                onChanged: (value) {
                                  setState(() {
                                    notesColumn = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _ColumnSelector(
                                value: titleColumn,
                                labelText: 'Title column',
                                columns: headersToSelect,
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
                  );
                }
                return SizedBox();
              },
            ),
          ],
        ),
        buildStep(
          index: 2,
          title: 'Column for account',
          description:
              'Select the column where the account to which each transaction belongs is specified. You can also select a default account in case we cannot find the account you want. If a default account is not specified, we will create one with the same name ',
          content: [],
        ),
        buildStep(
          index: 3,
          title: 'Column for category',
          description:
              'Specify the column where the transaction category name is located. You must specify a default category so that we assign this category to transactions, in case the category cannot be found',
          content: [],
        ),
        buildStep(
          index: 4,
          title: 'Column for date',
          description:
              'Select the column where the date of each transaction is specified. If not specified, transactions will be created with the current date',

          content: [],
        ),
        buildStep(
          index: 5,
          title: 'other columns',
          description: 'Specifies the columns for other optional transaction attributes',
          content: [],
        ),
      ],
    );
  }
}

class _ColumnSelector extends StatelessWidget {
  const _ColumnSelector({
    required this.value,
    required this.columns,
    this.labelText,
    this.isNullable = true,
    required this.onChanged,
  });

  final int? value;
  final Iterable<String> columns;
  final String? labelText;
  final bool isNullable;
  final void Function(int? value) onChanged;

  Future<String?> _showModal(BuildContext context, [String? userId]) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SizedBox();
        // return DropdownButtonFormField<int>(
        //   value: value,
        //   decoration: InputDecoration(labelText: labelText),
        //   items: [
        //     if (isNullable) DropdownMenuItem(value: null, child: Text('Unspecified')),
        //     ...List.generate(
        //       columns.length,
        //       (index) => DropdownMenuItem(
        //         value: csvHeaders!.toList().indexWhere((element) => element == columns.toList()[index]),
        //         child: Text(columns.toList()[index]),
        //       ),
        //     ),
        //   ],
        //   onChanged: (value) {
        //     if (dateColumn == value) dateColumn = null;
        //     if (notesColumn == value) notesColumn = null;
        //     if (titleColumn == value) titleColumn = null;
        //     if (amountColumn == value) amountColumn = null;
        //     if (accountColumn == value) accountColumn = null;
        //     if (categoryColumn == value) categoryColumn = null;

        //     onChanged(value);
        //   },
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(labelText: labelText),
      items: [
        if (isNullable) DropdownMenuItem(value: null, child: Text('Unspecified')),
        ...List.generate(
          columns.length,
          (index) => DropdownMenuItem(
            value: csvHeaders!.toList().indexWhere((element) => element == columns.toList()[index]),
            child: Text(columns.toList()[index]),
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
    // return TextFormField(
    //   controller: TextEditingController(text: value?.toString() ?? 'Unspecified'),
    //   readOnly: true,
    //   // validator: (_) => fieldValidator(inputValue, isRequired: isRequired),
    //   onTap: () => _showModal(context),
    //   autovalidateMode: AutovalidateMode.onUserInteraction,
    //   decoration: InputDecoration(
    //     labelText: labelText,
    //     suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
    //     prefixIcon: Container(
    //       margin: const EdgeInsets.fromLTRB(14, 8, 8, 8),
    //       // child: IconDisplayer(mainColor: iconColor, supportedIcon: icon),
    //     ),
    //   ),
    // );
  }
}

class _SelectCsvButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ImportTransactionsCubit>().readFile(),
      child: Material(
        color: Colors.grey.withAlpha(128),
        shape: RoundedRectangleBorder(side: BorderSide(width: 1.0), borderRadius: BorderRadius.circular(12.0)),
        child: SizedBox(
          height: 150.0,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 68.0),
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

class _CsvPreviewTable extends StatelessWidget {
  const _CsvPreviewTable(this.csvHeaders, this.csvData, {super.key, this.rowsToPreview = 5});

  final List<String> csvHeaders;
  final List<List<dynamic>> csvData;
  final int rowsToPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith<Color?>((states) => context.color.primary.withAlpha(50)),
            clipBehavior: Clip.hardEdge,
            headingTextStyle: context.textTheme.labelLarge,
            dataTextStyle: context.textTheme.bodySmall,
            columns: csvHeaders.map((item) => DataColumn(label: Text(item))).toList(),
            rows:
                csvData.sublist(0, rowsToPreview > csvData.length ? null : rowsToPreview).map((row) {
                  return DataRow(cells: row.map((item) => DataCell(Text(item.toString()))).toList());
                }).toList(),
          ),
        ),
        if (csvData.length - rowsToPreview >= 1)
          Text(
            '+${csvData.length - rowsToPreview} rows',
            textAlign: TextAlign.left,
            style: context.textTheme.labelSmall,
          ),
        const SizedBox(height: 12.0),
      ],
    );
  }
}

class _Selector extends StatelessWidget {
  const _Selector({
    super.key,
    required this.title,
    this.inputValue,
    // required this.icon,
    this.iconColor,
    required this.onClick,
    this.isRequired = false,
  });

  final String title;
  final String? inputValue;
  // final SupportedIcon? icon;
  final Color? iconColor;
  final Function onClick;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
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
          // child: IconDisplayer(mainColor: iconColor ?? context.color.primary, supportedIcon: icon),
        ),
      ),
    );
  }
}
