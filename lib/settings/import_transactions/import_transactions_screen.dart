import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/widget/account_picker_widget.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common/presentations/widgets/date_format_picker.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/import_transactions/cubit/import_transactions_cubit.dart';
import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/transactions/widgets/transaction_type_selector_form_field.dart';

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
  // late final List<_Step> _steps;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _dateFormatController = TextEditingController(text: 'yyyy-MM-dd HH:mm:ss');

  Step buildStep(BuildContext context, _Step step) {
    Widget? description;

    if (step.description != null) {
      description = DefaultTextStyle(style: context.textTheme.bodySmall!, child: step.description!);
    }

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
          children: <Widget>[?description, step.content],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Move the steps initialization to initState
    final cubit = context.read<ImportTransactionsCubit>();

    final _steps = [
      _Step(
        index: 0,
        title: const Text('Select CSV file'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text('${state.csvData.length} rows loaded');
            }

            return SizedBox.shrink();
          },
        ),
        description: const Text('Make sure it has a first row that describes the name of each column'),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loading) {
              return LoadingAnimationWidget.staggeredDotsWave(color: context.colors.primary, size: 48.0);
            }
            if (state.status == ImportTransactionsStatus.error) {
              return Text(state.errorMsg!, style: TextStyle(color: context.colors.error));
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
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(enabled: state.isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return FilledButton.tonalIcon(
                  onPressed: () => cubit.readFile(),
                  icon: state.isLoaded ? const Icon(Icons.restore_rounded) : const Icon(Icons.upload_file_rounded),
                  label: state.isLoaded ? const Text('Select again') : const Text('Select file'),
                );
              },
            ),
          ];
        },
      ),
      _Step(
        index: 1,
        title: const Text('Select column for amount'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text(
                '\'${state.amountColumn != null ? state.csvHeaders[state.amountColumn!] : '~~ UNSPECIFIED ~~'}\' column is selected',
              );
            }
            return SizedBox();
          },
        ),
        description: const Text(
          'Select the column where the total value of each transaction is specified.'
          ' Use a point as a decimal separator.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return _ColumnSelector(
                // value: state.columns[CsvColumn.amount],
                value: state.amountColumn,
                allColumns: state.csvHeaders.asMap(),
                onChanged: cubit.updateAmountColumn,
                // onChanged: (value) => cubit.updateColumn(CsvColumn.amount, value);
              );
            }
            return SizedBox();
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(
                  enabled: state.isLoaded && state.amountColumn != null,
                  onTap: details.onStepContinue,
                );
              },
            ),
          ];
        },
      ),
      _Step(
        index: 2,
        title: const Text('Select column for quantity'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text(
                '\'${state.quantityColumn != null ? state.csvHeaders[state.quantityColumn!] : '~~ UNSPECIFIED ~~'}\' column is selected',
              );
            }
            return SizedBox();
          },
        ),
        description: const Text(
          'Select the column where the quantities (units) of each transaction is specified.'
          ' Use a point as a decimal separator.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return _ColumnSelector(
                // value: state.columns[CsvColumn.amount],
                value: state.quantityColumn,
                allColumns: state.csvHeaders.asMap(),
                columnsToExclude: [state.amountColumn],
                onChanged: cubit.updateQuantityColumn,
                // onChanged: (value) => cubit.updateColumn(CsvColumn.quantity, value);
              );
            }
            return SizedBox();
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(
                  enabled: state.isLoaded && state.quantityColumn != null,
                  onTap: details.onStepContinue,
                );
              },
            ),
          ];
        },
      ),
      _Step(
        index: 3,
        title: const Text('Select column for account'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text(
                '\'${state.accountColumn != null ? state.csvHeaders[state.accountColumn!] : '~~ UNSPECIFIED ~~'}\' column is selected',
              );
            }
            return SizedBox();
          },
        ),
        description: const Text(
          'Select the column where the account to which each transaction belongs is specified.'
          ' You can also select a default account in case we cannot find the account you want.'
          ' If a default account is not specified, we will create one with the same name.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                spacing: 12.0,
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.account],
                    value: state.accountColumn,
                    allColumns: state.csvHeaders.asMap(),
                    // columnsToExclude: [state.columns[CsvColumn.amount]],
                    columnsToExclude: [state.amountColumn, state.quantityColumn],
                    onChanged: cubit.updateAccountColumn,
                    // onChanged: (value) => cubit.updateColumn(CsvColumn.account, value),
                  ),

                  AsyncFormField<InveslyAccount>(
                    initialValue: cubit.state.defaultAccount,
                    validator: (value) {
                      if (value == null) {
                        return 'Can\'t be empty';
                      }
                      return null;
                    },
                    onTapCallback: (value) async {
                      final newAccount = await InveslyAccountPickerWidget.showModal(context, value?.id);
                      return newAccount;
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      cubit.updateDefaultAccount(value);
                    },
                    childBuilder: (value) {
                      if (value == null) {
                        return Text(
                          'Select an account',
                          style: TextStyle(color: context.theme.disabledColor),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return Row(
                        spacing: 16.0,
                        children: <Widget>[
                          CircleAvatar(foregroundImage: AssetImage(value.avatar), radius: 10.0),
                          Text(value.name, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
                        ],
                      );
                    },
                    trailing: const Icon(Icons.arrow_drop_down_rounded),
                  ).withLabel('Default account'),
                ],
              );
            }
            return SizedBox();
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(
                  enabled: state.isLoaded && state.accountColumn != null && state.defaultAccount != null,
                  onTap: details.onStepContinue,
                );
              },
            ),
          ];
        },
      ),
      _Step(
        index: 4,
        title: const Text('Select column for transaction type'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text(
                '\'${state.typeColumn != null ? state.csvHeaders[state.typeColumn!] : '~~ UNSPECIFIED ~~'}\' column is selected',
              );
            }
            return SizedBox();
          },
        ),
        description: const Text(
          'Specify the column where the transaction type name is specified.'
          ' The types can be integer (0 for investment and 1 for redemption or dividend) or'
          ' can be one character (like I, R, D) or can be string.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                spacing: 12.0,
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.type],
                    value: state.typeColumn,
                    allColumns: state.csvHeaders.asMap(),
                    // columnsToExclude: [state.columns[CsvColumn.amount], state.columns[CsvColumn.account]],
                    columnsToExclude: [state.amountColumn, state.quantityColumn, state.accountColumn],
                    onChanged: cubit.updateTypeColumn,
                    // onChanged: (value) => cubit.updateColumn(CsvColumn.type, value),
                  ),

                  TransactionTypeSelectorFormField(
                    initialValue: cubit.state.defaultType,
                    onChanged: (value) {
                      if (value == null) return;
                      cubit.updateDefaultType(value);
                    },
                  ).withLabel('Default transaction type'),
                ],
              );
            }
            return SizedBox();
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(
                  enabled: state.isLoaded && state.typeColumn != null,
                  onTap: details.onStepContinue,
                );
              },
            ),
          ];
        },
      ),
      _Step(
        index: 5,
        title: const Text('Select column for date'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Text(
                '\'${state.dateColumn != null ? state.csvHeaders[state.dateColumn!] : '~~ UNSPECIFIED ~~'}\' column is selected',
              );
            }
            return SizedBox();
          },
        ),
        description: const Text(
          'Select the column where the date of each transaction is specified.'
          ' If not specified, transactions will be created with the current date',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.status == ImportTransactionsStatus.loaded) {
              return Column(
                spacing: 12.0,
                children: <Widget>[
                  _ColumnSelector(
                    // value: state.columns[CsvColumn.date],
                    value: state.dateColumn,
                    allColumns: state.csvHeaders.asMap(),
                    columnsToExclude: [
                      // state.columns[CsvColumn.amount], state.columns[CsvColumn.account], state.columns[CsvColumn.category],
                      state.amountColumn, state.quantityColumn, state.accountColumn, state.typeColumn,
                    ],
                    onChanged: cubit.updateDateColumn,
                    // onChanged: (value) => cubit.updateColumn(CsvColumn.date, value);
                  ),

                  AsyncFormField<String>(
                    initialValue: cubit.state.defaultDateFormat,
                    onTapCallback: (value) async {
                      final newDateFormat = await InveslyDateFormatPicker.showModal(context, value);
                      return newDateFormat;
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      cubit.updateDefaultDateFormat(value);
                    },
                    childBuilder: (value) {
                      if (value == null) {
                        return Text(
                          'Select a date format',
                          style: TextStyle(color: context.theme.disabledColor),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return Text(value, overflow: TextOverflow.ellipsis);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Can\'t be empty';
                      }
                      return null;
                    },
                    trailing: const Icon(Icons.arrow_drop_down_rounded),
                  ).withLabel('Default date format'),
                ],
              );
            }
            return SizedBox();
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(
                  enabled: state.isLoaded && state.dateColumn != null,
                  onTap: details.onStepContinue,
                );
              },
            ),
          ];
        },
      ),
      _Step(
        index: 6,
        title: const Text('Other columns'),
        description: const Text('Specifies the columns for other optional transaction attributes'),
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
                      state.typeColumn,
                      state.dateColumn,
                      state.titleColumn,
                    ],
                    onChanged: (value) {
                      // cubit.updateColumn(CsvColumn.notes, value);
                      cubit.updateNotesColumn(value);
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
                      state.typeColumn,
                      state.dateColumn,
                      state.notesColumn,
                    ],
                    onChanged: (value) {
                      // cubit.updateColumn(CsvColumn.title, value);
                      cubit.updateTitleColumn(value);
                    },
                  ),
                ],
              );
            }
            return SizedBox();
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
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
          ];
        },
      ),
    ];

    return Stepper(
      type: StepperType.vertical,
      currentStep: currentStep,
      onStepTapped: (value) => setState(() => currentStep = value),
      controlsBuilder: (context, details) {
        final step = _steps.elementAt(currentStep);
        if (step.controlsBuilder == null) {
          return SizedBox.shrink();
        }

        return Row(spacing: 8.0, children: step.controlsBuilder!(context, details));
      },
      onStepContinue: currentStep < _steps.length - 1 ? () => setState(() => currentStep++) : null,
      steps: _steps.map<Step>((step) => buildStep(context, step)).toList(),
    );
  }

  ButtonStyleButton _buildNextButton({VoidCallback? onTap, bool enabled = true}) {
    return FilledButton.icon(
      onPressed: enabled ? onTap : null,
      icon: const Icon(Icons.check_rounded),
      label: const Text('Next'),
    );
  }
}

class _Step {
  final int index;
  final Widget title;
  final Widget? subtitle;
  final Widget? description;
  final Widget content;
  final List<Widget> Function(BuildContext context, ControlsDetails details)? controlsBuilder;

  _Step({
    required this.index,
    required this.title,
    this.subtitle,
    this.description,
    required this.content,
    this.controlsBuilder,
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

  // List<DropdownMenuEntry<int>> get _entries => [
  //   // DropdownMenuEntry(value: null, label: '~~ UNSPECIFIED ~'),
  //   ...allColumns.entries
  //   .whereNot((entry) => columnsToExclude.contains(entry.key))
  //   .map((entry) => DropdownMenuEntry(value: entry.key, label: entry.value)),
  // ];

  Future<int?> _showModal(BuildContext context) async {
    final columnIndex = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                  child: Text('Select a column', style: context.textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                ),
                Section(
                  tiles: allColumns.entries.map((entry) {
                    final isSelectionAllowed = !columnsToExclude.contains(entry.key);
                    return SectionTile(
                      title: Text(entry.value.trim()),
                      onTap: () => context.pop(entry.key),
                      trailingIcon: entry.key == value
                          ? const Icon(Icons.check_rounded)
                          : isSelectionAllowed
                          ? null
                          : const Icon(Icons.cancel_rounded),
                      enabled: isSelectionAllowed,
                      selected: entry.key == value,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (columnIndex == null) return value;
    return columnIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncFormField<int>(
      initialValue: value,
      onTapCallback: (_) async {
        final columnIndex = await _showModal(context);
        return columnIndex;
      },
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
      childBuilder: (value) {
        $logger.d(value);
        return Text(allColumns[value] ?? '~~ UNSPECIFIED ~~');
      },
      trailing: const Icon(Icons.arrow_drop_down_rounded),
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
        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        prefixIcon: Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          // child: IconDisplayer(mainColor: iconColor ?? context.color.primary, supportedIcon: icon),
        ),
      ),
    );
  }
}
