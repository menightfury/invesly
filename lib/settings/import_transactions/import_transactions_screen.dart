import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common_libs.dart';
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

  final TextEditingController _dateFormatController = TextEditingController(text: 'yyyy-MM-dd HH:mm:ss');

  Step buildStep({required int index, required String title, String? description, required Widget content}) {
    return Step(
      title: Text(title),
      isActive: currentStep >= index,
      state:
          currentStep > index
              ? StepState.complete
              : currentStep == index
              ? StepState.editing
              : StepState.disabled,
      content: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          mainAxisSize: MainAxisSize.min,
          children: [if (description != null) Text(description, style: context.textTheme.bodySmall), content],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      type: StepperType.vertical,
      currentStep: currentStep,
      onStepTapped: (value) => setState(() => currentStep = value),
      controlsBuilder: (context, details) {
        return BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            return Row(
              spacing: 8.0,
              children: <Widget>[
                if (state is ImportTransactionsLoadedState)
                  Flexible(
                    fit: currentStep == 5 ? FlexFit.tight : FlexFit.loose,
                    child: FilledButton.icon(
                      onPressed: currentStep == 5 ? () {} : details.onStepContinue,
                      icon: currentStep == 5 ? const Icon(Icons.upload_file_rounded) : const Icon(Icons.check_rounded),
                      label: currentStep == 5 ? Text('Import CSV') : Text('Continue'),
                    ),
                  ),

                if (currentStep == 0)
                  Flexible(
                    child: TextButton.icon(
                      onPressed: () => context.read<ImportTransactionsCubit>().readFile(),
                      icon:
                          state is ImportTransactionsLoadedState
                              ? const Icon(Icons.restore_rounded)
                              : const Icon(Icons.upload_file_rounded),
                      label:
                          state is ImportTransactionsLoadedState
                              ? const Text('Select again')
                              : const Text('Select file'),
                    ),
                  ),
              ],
            );
          },
        );
      },
      onStepContinue: () => setState(() => currentStep++),
      steps: [
        buildStep(
          index: 0,
          title: 'Select CSV file',
          description: 'Make sure it has a first row that describes the name of each column',
          content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state is ImportTransactionsLoadingState) {
                return LoadingAnimationWidget.staggeredDotsWave(color: context.colors.primary, size: 48.0);
              }

              if (state is ImportTransactionsErrorState) {
                return Text(state.errorMsg, style: TextStyle(color: Colors.redAccent));
              }

              if (state is ImportTransactionsLoadedState) {
                return AnimatedExpanded(
                  axis: Axis.vertical,
                  expand: true,
                  child: _CsvPreviewTable(state.csvHeaders, state.csvData),
                ); // TODO: Animation not working
              }

              return SizedBox();
            },
          ),
        ),
        buildStep(
          index: 1,
          title: 'Column for amount ',
          description:
              'Select the column where the total value of each transaction is specified. Use positive values for investment and negative values for redemption or dividends. Use a point as a decimal separator.',
          content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state is ImportTransactionsLoadedState) {
                return _ColumnSelector<int?>(
                  value: state.columns[CsvColumn.amount],
                  allColumns: state.csvHeaders.asMap(),
                  onChanged: (value) {
                    context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.amount, value);
                  },
                );
              }
              return SizedBox();
            },
          ),
        ),
        buildStep(
          index: 2,
          title: 'Column for account',
          description:
              'Select the column where the account to which each transaction belongs is specified. You can also select a default account in case we cannot find the account you want. If a default account is not specified, we will create one with the same name.',
          content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state is ImportTransactionsLoadedState) {
                return Column(
                  children: <Widget>[
                    _ColumnSelector<int?>(
                      value: state.columns[CsvColumn.account],
                      allColumns: state.csvHeaders.asMap(),
                      columnsToExclude: [state.columns[CsvColumn.amount]],
                      onChanged: (value) {
                        context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.account, value);
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
                  ],
                );
              }
              return SizedBox();
            },
          ),
        ),
        buildStep(
          index: 3,
          title: 'Column for category',
          description:
              'Specify the column where the transaction category name is located. You must specify a default category so that we assign this category to transactions, in case the category cannot be found.',
          content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state is ImportTransactionsLoadedState) {
                return Column(
                  children: <Widget>[
                    _ColumnSelector<int?>(
                      value: state.columns[CsvColumn.category],
                      allColumns: state.csvHeaders.asMap(),
                      columnsToExclude: [state.columns[CsvColumn.amount], state.columns[CsvColumn.account]],
                      onChanged: (value) {
                        context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.category, value);
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
                  ],
                );
              }
              return SizedBox();
            },
          ),
        ),
        buildStep(
          index: 4,
          title: 'Column for date',
          description:
              'Select the column where the date of each transaction is specified. If not specified, transactions will be created with the current date',
          content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state is ImportTransactionsLoadedState) {
                return Column(
                  children: <Widget>[
                    _ColumnSelector<int?>(
                      value: state.columns[CsvColumn.date],
                      allColumns: state.csvHeaders.asMap(),
                      columnsToExclude: [
                        state.columns[CsvColumn.amount],
                        state.columns[CsvColumn.account],
                        state.columns[CsvColumn.category],
                      ],
                      onChanged: (value) {
                        context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.date, value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateFormatController,
                      enabled: state.columns[CsvColumn.date] != null,
                      decoration: const InputDecoration(labelText: 'Date format'),
                      // validator: (value) => fieldValidator(value),
                      autovalidateMode: AutovalidateMode.always,
                    ),
                  ],
                );
              }
              return SizedBox();
            },
          ),
        ),
        buildStep(
          index: 5,
          title: 'other columns',
          description: 'Specifies the columns for other optional transaction attributes',
          content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state is ImportTransactionsLoadedState) {
                return Column(
                  children: <Widget>[
                    _ColumnSelector<int?>(
                      value: state.columns[CsvColumn.notes],
                      labelText: 'Note column',
                      allColumns: state.csvHeaders.asMap(),
                      columnsToExclude: [
                        state.columns[CsvColumn.amount],
                        state.columns[CsvColumn.account],
                        state.columns[CsvColumn.category],
                        state.columns[CsvColumn.date],
                        state.columns[CsvColumn.title],
                      ],
                      onChanged: (value) {
                        context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.notes, value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _ColumnSelector<int?>(
                      value: state.columns[CsvColumn.title],
                      labelText: 'Title column',
                      allColumns: state.csvHeaders.asMap(),
                      columnsToExclude: [
                        state.columns[CsvColumn.amount],
                        state.columns[CsvColumn.account],
                        state.columns[CsvColumn.category],
                        state.columns[CsvColumn.date],
                        state.columns[CsvColumn.notes],
                      ],
                      onChanged: (value) {
                        context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.title, value);
                      },
                    ),
                  ],
                );
              }
              return SizedBox();
            },
          ),
        ),
      ],
    );
  }
}

class _ColumnSelector<T> extends StatelessWidget {
  const _ColumnSelector({
    required this.value,
    required this.allColumns,
    this.columnsToExclude = const [],
    this.labelText,
    required this.onChanged,
  });

  final T? value;
  final Map<T, String> allColumns;
  final List<T> columnsToExclude;
  final String? labelText;
  final ValueChanged<T?> onChanged;

  List<DropdownMenuEntry<T?>> get _entries => [
    DropdownMenuEntry(value: null, label: 'Unspecified'),
    ...allColumns.entries
        .whereNot((entry) => columnsToExclude.contains(entry.key))
        .map((entry) => DropdownMenuEntry(value: entry.key, label: entry.value)),
  ];

  Future<DropdownMenuEntry<T?>?> _showModal(BuildContext context) async {
    return await showModalBottomSheet<DropdownMenuEntry<T?>?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: ColumnBuilder(
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return ListTile(
                title: Text(entry.label),
                leading: entry.leadingIcon,
                trailing: entry.trailingIcon,
                onTap: () => context.pop(entry),
              );
            },
            itemCount: _entries.length,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return DropdownMenu<T?>(
    //   initialSelection: value,
    //   label: labelText != null ? Text(labelText!) : null,
    //   enableSearch: false,
    //   dropdownMenuEntries: [
    //     DropdownMenuEntry(label: 'Unspecified', value: null),
    //     ...columns.entries.map((entry) => DropdownMenuEntry(label: entry.value, value: entry.key)),
    //   ],
    //   menuStyle: MenuStyle(
    //     shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),
    //     padding: WidgetStatePropertyAll(const EdgeInsets.all(8.0)),
    //   ),
    //   onSelected: onChanged,
    // );

    return Tappable(
      trailing: const Icon(Icons.arrow_drop_down_rounded),
      onTap: () async {
        final value = await _showModal(context);
        onChanged(value?.value);
      },
      child: Text(allColumns[value] ?? 'Unspecified'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: DataTable(
            headingTextStyle: context.textTheme.labelLarge,
            headingRowColor: WidgetStateProperty.all<Color?>(context.colors.primary.withAlpha(50)),
            columnSpacing: 24.0,
            horizontalMargin: 12.0,
            border: TableBorder.all(
              color: context.colors.primary.withAlpha(100),
              width: 1.0,
              borderRadius: BorderRadius.circular(12.0),
            ),

            clipBehavior: Clip.hardEdge,
            dataTextStyle: context.textTheme.bodySmall,
            columns: csvHeaders.map((item) => DataColumn(label: Text(item))).toList(),
            rows:
                csvData.sublist(0, rowsToPreview > csvData.length ? null : rowsToPreview).map((row) {
                  return DataRow(cells: row.map((item) => DataCell(Text(item.toString()))).toList());
                }).toList(),
          ),
        ),
        if (csvData.length - rowsToPreview >= 1)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '+${csvData.length - rowsToPreview} rows',
              textAlign: TextAlign.left,
              style: context.textTheme.labelSmall,
            ),
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
