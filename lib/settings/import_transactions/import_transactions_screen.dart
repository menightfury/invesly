import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/widget/account_picker_widget.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common/presentations/widgets/date_format_picker.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/import_transactions/cubit/import_transactions_cubit.dart';
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
            final i = state.fields[TransactionField.amount];
            return Text('\'${i != null ? state.csvHeaders[i] : '~~ UNSPECIFIED ~~'}\' column is selected');
          },
        ),
        description: const Text(
          'Select the column where the total value of each transaction is specified.'
          ' Use a point as a decimal separator.',
        ),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            return _ColumnSelector(
              enabled: state.status == ImportTransactionsStatus.loaded,
              modalTitle: const Text('Select column for amount'),
              value: state.fields[TransactionField.amount],
              // value: state.amountColumn,
              allColumns: state.csvHeaders.asMap(),
              // onChanged: cubit.updateAmountColumn,
              onChanged: (value) => cubit.updateField(TransactionField.amount, value),
            );
          },
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return _buildNextButton(
                  // enabled: state.isLoaded && state.amountColumn != null,
                  enabled: state.isLoaded && state.fields[TransactionField.amount] != null,
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
            return _ColumnSelector(
              enabled: state.status == ImportTransactionsStatus.loaded,
              modalTitle: const Text('Select column for quantity'),
              value: state.fields[TransactionField.quantity],
              // value: state.quantityColumn,
              allColumns: state.csvHeaders.asMap(),
              columnIndicesToExclude: [state.amountColumn],
              onChanged: cubit.updateQuantityColumn,
              // onChanged: (value) => cubit.updateColumn(TransactionField.quantity, value);
            );
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
            return Column(
              spacing: 12.0,
              children: <Widget>[
                _ColumnSelector(
                  enabled: state.status == ImportTransactionsStatus.loaded,
                  modalTitle: const Text('Select column for account'),
                  // value: state.fields[TransactionField.account],
                  value: state.accountColumn,
                  allColumns: state.csvHeaders.asMap(),
                  // columnsToExclude: [state.fields[TransactionField.amount]],
                  columnIndicesToExclude: [state.amountColumn, state.quantityColumn],
                  onChanged: cubit.updateAccountColumn,
                  // onChanged: (value) => cubit.updateColumn(TransactionField.account, value),
                ),

                AsyncFormField<InveslyAccount>(
                  enabled: state.status == ImportTransactionsStatus.loaded,
                  initialValue: cubit.state.defaultAccount,
                  validator: (value) {
                    if (value == null) {
                      return 'Can\'t be empty';
                    }
                    return null;
                  },
                  onTapCallback: (value) async {
                    final newAccount = await InveslyAccountPickerWidget.showModal(context, value?.id);
                    return newAccount ?? value;
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
        title: const Text('Select column for AMC'),
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
            return _ColumnSelector(
              enabled: state.status == ImportTransactionsStatus.loaded,
              modalTitle: const Text('Select column for AMC'),
              // value: state.fields[TransactionField.account],
              value: state.amcColumn,
              allColumns: state.csvHeaders.asMap(),
              // columnsToExclude: [state.fields[TransactionField.amount]],
              columnIndicesToExclude: [state.amountColumn, state.quantityColumn],
              onChanged: cubit.updateAmcColumn,
              // onChanged: (value) => cubit.updateColumn(TransactionField.account, value),
            );
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
        index: 5,
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
            return Column(
              spacing: 12.0,
              children: <Widget>[
                _ColumnSelector(
                  enabled: state.status == ImportTransactionsStatus.loaded,
                  modalTitle: const Text('Select column for transaction type'),
                  // value: state.fields[TransactionField.type],
                  value: state.typeColumn,
                  allColumns: state.csvHeaders.asMap(),
                  // columnsToExclude: [state.fields[TransactionField.amount], state.fields[TransactionField.account]],
                  columnIndicesToExclude: [state.amountColumn, state.quantityColumn, state.accountColumn],
                  onChanged: cubit.updateTypeColumn,
                  // onChanged: (value) => cubit.updateColumn(TransactionField.type, value),
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
        index: 6,
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
            return Column(
              spacing: 12.0,
              children: <Widget>[
                _ColumnSelector(
                  enabled: state.status == ImportTransactionsStatus.loaded,
                  // value: state.fields[TransactionField.date],
                  value: state.dateColumn,
                  allColumns: state.csvHeaders.asMap(),
                  columnIndicesToExclude: [
                    // state.fields[TransactionField.amount], state.fields[TransactionField.account], state.fields[TransactionField.category],
                    state.amountColumn, state.quantityColumn, state.accountColumn, state.typeColumn,
                  ],
                  onChanged: cubit.updateDateColumn,
                  // onChanged: (value) => cubit.updateColumn(TransactionField.date, value);
                ),

                AsyncFormField<String>(
                  enabled: state.status == ImportTransactionsStatus.loaded,
                  initialValue: cubit.state.defaultDateFormat,
                  onTapCallback: (value) async {
                    final newDateFormat = await InveslyDateFormatPicker.showModal(context, value);
                    return newDateFormat ?? value;
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
        index: 7,
        title: const Text('Select other columns'),
        description: const Text('Specifies the columns for other optional transaction attributes'),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            return _ColumnSelector(
              enabled: state.status == ImportTransactionsStatus.loaded,
              // value: state.fields[TransactionField.notes],
              modalTitle: Text('Select column for notes'),
              value: state.notesColumn,
              allColumns: state.csvHeaders.asMap(),
              columnIndicesToExclude: [
                // state.fields[TransactionField.amount],
                // state.fields[TransactionField.account],
                // state.fields[TransactionField.category],
                // state.fields[TransactionField.date],
                // state.fields[TransactionField.title],
                state.amountColumn,
                state.quantityColumn,
                state.accountColumn,
                state.amcColumn,
                state.typeColumn,
                state.dateColumn,
              ],
              onChanged: cubit.updateNotesColumn,
              // onChanged: (value) => cubit.updateColumn(TransactionField.notes, value);
            ).withLabel('Notes column');
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
    super.key,
    required this.field,
    required this.value,
    this.modalTitle,
    // required this.allColumns,
    // this.columnIndicesToExclude = const [],
    required this.onChanged,
    // this.enabled = true,
  });

  final TransactionField field;
  final Widget? modalTitle;
  final int? value;
  // final Map<int, String> allColumns;
  // final List<int?> columnIndicesToExclude;
  final ValueChanged<int> onChanged;
  // final bool enabled;

  // List<DropdownMenuEntry<int>> get _entries => [
  //   // DropdownMenuEntry(value: null, label: '~~ UNSPECIFIED ~'),
  //   ...allColumns.entries
  //   .whereNot((entry) => columnsToExclude.contains(entry.key))
  //   .map((entry) => DropdownMenuEntry(value: entry.key, label: entry.value)),
  // ];

  Future<int?> _showModal(BuildContext context, List<String> fields) async {
    final state = context.read<ImportTransactionsCubit>().state;

    return await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final titleWidget = DefaultTextStyle(
          style: context.textTheme.labelLarge!,
          child: modalTitle ?? Text('Select a column', overflow: TextOverflow.ellipsis),
        );
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0), child: titleWidget),
                Section(
                  tiles: state.csvHeaders.asMap().entries.map((entry) {
                    final isSelectionAllowed = !state.fields.values.contains(entry.key);
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
      builder: (context, state) {
        return AsyncFormField<int>(
          enabled: state.status == ImportTransactionsStatus.loaded,
          initialValue: value,
          onTapCallback: (value) async {
            final columnIndex = await _showModal(context, state.csvHeaders);
            return columnIndex ?? value;
          },
          onChanged: (value) {
            if (value == null) return;
            onChanged(value);
          },
          childBuilder: (value) {
            return Text(allColumns[value] ?? '~~ UNSPECIFIED ~~');
          },
          trailing: const Icon(Icons.arrow_drop_down_rounded),
        );
      },
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
