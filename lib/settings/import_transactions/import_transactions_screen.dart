import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
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
  late final List<_Step> _steps;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _steps = [
      _Step(
        index: 0,
        title: Text('Select CSV file'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text('${state.csvData.length} rows loaded');
            }

            return SizedBox.shrink();
          },
        ),
        description: Text('Make sure it has a first row that describes the name of each column'),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loading) {
              return LoadingAnimationWidget.staggeredDotsWave(color: context.colors.primary, size: 48.0);
            }
            if (state.status == ImportTransactionsStatus.error) {
              return Text(state.errorMsg!, style: TextStyle(color: Colors.redAccent));
            }
            if (state.status == ImportTransactionsStatus.loaded) {
              return AnimatedExpanded(
                axis: Axis.vertical,
                expand: true,
                child: _CsvPreviewTable(state.csvHeaders, state.csvData),
              ); // TODO: Animation not working
            }

            return SizedBox();
          },
        ),
        buttons: [
          BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              return FilledButton.tonalIcon(
                onPressed: () => context.read<ImportTransactionsCubit>().readFile(),
                icon: state.isLoaded ? const Icon(Icons.restore_rounded) : const Icon(Icons.upload_file_rounded),
                label: state.isLoaded ? const Text('Select again') : const Text('Select file'),
              );
            },
          ),
        ],
      ),
      _Step(
        index: 1,
        title: Text('Select column for amount'),
        // subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
        //   builder: (context, state) {
        //     // if (state.status == ImportTransactionsStatus.loaded) {
        //     if (state.status == ImportTransactionsStatus.loaded) {
        //       return Text(state.csvHeaders);
        //     }
        //     return SizedBox();
        //   },
        // ),
        description: Text(
          'Select the column where the total value of each transaction is specified.'
          ' Use positive values for investment and negative values for redemption or dividends.'
          ' Use a point as a decimal separator.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return _ColumnSelector(
                // value: state.columns[CsvColumn.amount],
                value: state.amountColumn,
                allColumns: state.csvHeaders.asMap(),
                onChanged: (value) {
                  // context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.amount, value);
                  context.read<ImportTransactionsCubit>().updateAmountColumn(value);
                },
              );
            }
            return SizedBox();
          },
        ),
      ),
      _Step(
        index: 2,
        title: Text('Column for account'),
        description: Text(
          'Select the column where the account to which each transaction belongs is specified.'
          ' You can also select a default account in case we cannot find the account you want.'
          ' If a default account is not specified, we will create one with the same name.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.account],
                    value: state.accountColumn,
                    allColumns: state.csvHeaders.asMap(),
                    // columnsToExclude: [state.columns[CsvColumn.amount]],
                    columnsToExclude: [state.amountColumn],
                    onChanged: (value) {
                      // context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.account, value);
                      context.read<ImportTransactionsCubit>().updateAccountColumn(value);
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
      _Step(
        index: 3,
        title: Text('Column for category'),
        description: Text(
          'Specify the column where the transaction category name is located.'
          ' You must specify a default category so that we assign this category to transactions,'
          ' in case the category cannot be found.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.category],
                    value: state.categoryColumn,
                    allColumns: state.csvHeaders.asMap(),
                    // columnsToExclude: [state.columns[CsvColumn.amount], state.columns[CsvColumn.account]],
                    columnsToExclude: [state.amountColumn, state.accountColumn],
                    onChanged: (value) {
                      // context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.category, value);
                      context.read<ImportTransactionsCubit>().updateCategoryColumn(value);
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
      _Step(
        index: 4,
        title: Text('Column for date'),
        description: Text(
          'Select the column where the date of each transaction is specified.'
          ' If not specified, transactions will be created with the current date',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.date],
                    value: state.dateColumn,
                    allColumns: state.csvHeaders.asMap(),
                    columnsToExclude: [
                      // state.columns[CsvColumn.amount], state.columns[CsvColumn.account], state.columns[CsvColumn.category],
                      state.amountColumn, state.accountColumn, state.categoryColumn,
                    ],
                    onChanged: (value) {
                      // context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.date, value);
                      context.read<ImportTransactionsCubit>().updateDateColumn(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateFormatController,
                    // enabled: state.columns[CsvColumn.date] != null,
                    enabled: state.dateColumn != null,
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
      _Step(
        index: 5,
        title: Text('Other columns'),
        description: Text('Specifies the columns for other optional transaction attributes'),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.notes],
                    value: state.notesColumn,
                    labelText: 'Note column',
                    allColumns: state.csvHeaders.asMap(),
                    columnsToExclude: [
                      // state.columns[CsvColumn.amount],
                      // state.columns[CsvColumn.account],
                      // state.columns[CsvColumn.category],
                      // state.columns[CsvColumn.date],
                      // state.columns[CsvColumn.title],
                      state.amountColumn,
                      state.accountColumn,
                      state.categoryColumn,
                      state.dateColumn,
                      state.titleColumn,
                    ],
                    onChanged: (value) {
                      // context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.notes, value);
                      context.read<ImportTransactionsCubit>().updateNotesColumn(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.title],
                    value: state.titleColumn,
                    labelText: 'Title column',
                    allColumns: state.csvHeaders.asMap(),
                    columnsToExclude: [
                      // state.columns[CsvColumn.amount],
                      // state.columns[CsvColumn.account],
                      // state.columns[CsvColumn.category],
                      // state.columns[CsvColumn.date],
                      // state.columns[CsvColumn.notes],
                      state.amountColumn,
                      state.accountColumn,
                      state.categoryColumn,
                      state.dateColumn,
                      state.notesColumn,
                    ],
                    onChanged: (value) {
                      // context.read<ImportTransactionsCubit>().updateColumn(CsvColumn.title, value);
                      context.read<ImportTransactionsCubit>().updateTitleColumn(value);
                    },
                  ),
                ],
              );
            }
            return SizedBox();
          },
        ),
        showContinueButton: false,
        buttons: <Widget>[
          BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
            builder: (context, state) {
              if (state.status == ImportTransactionsStatus.loaded) {
                return Flexible(
                  fit: FlexFit.tight,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Import CSV'),
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),
        ],
      ),
    ];
  }

  final TextEditingController _dateFormatController = TextEditingController(text: 'yyyy-MM-dd HH:mm:ss');

  Step buildStep(_Step step) {
    return Step(
      title: step.title,
      subtitle: currentStep > step.index ? step.subtitle : null,
      isActive: currentStep >= step.index,
      state: currentStep > step.index
          ? StepState.complete
          : currentStep == step.index
          ? StepState.editing
          : StepState.disabled,
      content: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[?step.description, step.content],
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
        final step = _steps.elementAt(currentStep);
        return Row(
          spacing: 8.0,
          children: <Widget>[
            if (step.showContinueButton)
              BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
                builder: (context, state) {
                  return Flexible(
                    fit: FlexFit.loose,
                    child: FilledButton.icon(
                      onPressed: state.isLoaded && step.enableContinueButton ? details.onStepContinue : null,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Continue'),
                    ),
                  );
                },
              ),

            if (step.buttons?.isNotEmpty ?? false) ...step.buttons!,
          ],
        );
      },
      onStepContinue: () => setState(() => currentStep++),
      steps: _steps.map<Step>(buildStep).toList(),
    );
  }
}

class _Step {
  final int index;
  final Widget title;
  final Widget? subtitle;
  final Widget? description;
  final Widget content;
  final List<Widget>? buttons;
  final bool showContinueButton;
  final bool enableContinueButton;

  _Step({
    required this.index,
    required this.title,
    this.subtitle,
    this.description,
    required this.content,
    this.showContinueButton = true,
    this.enableContinueButton = true,
    this.buttons,
  });
}

class _ColumnSelector extends StatelessWidget {
  const _ColumnSelector({
    required this.value,
    required this.allColumns,
    this.columnsToExclude = const [],
    this.labelText,
    required this.onChanged,
  });

  final int? value;
  final Map<int, String> allColumns;
  final List<int?> columnsToExclude;
  final String? labelText;
  final ValueChanged<int> onChanged;

  List<DropdownMenuEntry<int>> get _entries => [
    // DropdownMenuEntry(value: null, label: '~~ UNSPECIFIED ~'),
    ...allColumns.entries
    // .whereNot((entry) => columnsToExclude.contains(entry.key))
    .map((entry) => DropdownMenuEntry(value: entry.key, label: entry.value)),
  ];

  Future<DropdownMenuEntry<int>?> _showModal(BuildContext context) async {
    return await showModalBottomSheet<DropdownMenuEntry<int>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                child: Text('Select a column', style: context.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
              ),
              Section(
                tiles: _entries.map((entry) {
                  return SectionTile(
                    title: Text(entry.label.trim()),
                    onTap: () => context.pop(entry),
                    trailingIcon: entry.value == value ? const Icon(Icons.check_rounded) : null,
                    enabled: columnsToExclude.contains(entry.value),
                    selected: entry.value == value,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tappable(
      padding: const EdgeInsets.all(12.0),
      trailing: const Icon(Icons.arrow_drop_down_rounded),
      onTap: () async {
        final entry = await _showModal(context);
        if (entry == null) return;
        onChanged(entry.value);
      },
      content: Text(allColumns[value] ?? '~~ UNSPECIFIED ~~'),
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
            rows: csvData.sublist(0, rowsToPreview > csvData.length ? null : rowsToPreview).map((row) {
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
