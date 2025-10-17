import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/accounts/model/account_repository.dart';
import 'package:invesly/accounts/widget/account_picker_widget.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common/extensions/widget_extension.dart';
import 'package:invesly/common/presentations/animations/animated_expanded.dart';
import 'package:invesly/common/presentations/widgets/async_form_field.dart';
import 'package:invesly/common/presentations/widgets/date_format_picker.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/import_transactions/cubit/import_transactions_cubit.dart';
import 'package:invesly/settings/import_transactions/review_transactions_page.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';
import 'package:invesly/transactions/widgets/transaction_type_selector_form_field.dart';

class ImportTransactionsScreen extends StatelessWidget {
  const ImportTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Import transactions from CSV')),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => ImportTransactionsCubit(
            accountRepository: context.read<AccountRepository>(),
            amcRepository: context.read<AmcRepository>(),
            transactionRepository: context.read<TransactionRepository>(),
          ),
          child: _ImportTransactionsScreen(),
        ),
      ),
    );
  }
}

class _ImportTransactionsScreen extends StatefulWidget {
  const _ImportTransactionsScreen({super.key});

  @override
  State<_ImportTransactionsScreen> createState() => _ImportTransactionsScreenState();
}

class _ImportTransactionsScreenState extends State<_ImportTransactionsScreen> {
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
      subtitle: step.subtitle,
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
    final cubit = context.read<ImportTransactionsCubit>();
    // TODO: Move steps to initState
    final _steps = [
      _Step(
        index: 0,
        title: const Text('Select CSV file'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          buildWhen: (prevState, state) => prevState.csvStatus != state.csvStatus || prevState.csvData != state.csvData,
          builder: (context, state) {
            if (state.isCsvLoaded) {
              return Text('${state.csvData.length} rows loaded');
            }

            return SizedBox.shrink();
          },
        ),
        description: const Text('Make sure it has a first row that describes the name of each column'),
        content: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            if (state.isCsvLoading) {
              return LoadingAnimationWidget.staggeredDotsWave(color: context.colors.primary, size: 48.0);
            }
            if (state.isCsvError) {
              return Text(state.errorMsg!, style: TextStyle(color: context.colors.error));
            }
            if (state.isCsvLoaded) {
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
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded,
              builder: (context, isLoaded) {
                return _buildNextButton(enabled: isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded,
              builder: (context, isLoaded) {
                return FilledButton.tonalIcon(
                  onPressed: () => cubit.readFile(),
                  icon: isLoaded ? const Icon(Icons.restore_rounded) : const Icon(Icons.upload_file_rounded),
                  label: isLoaded ? const Text('Select again') : const Text('Select file'),
                );
              },
            ),
          ];
        },
      ),

      // ~ Amount
      _Step(
        index: 1,
        title: const Text('Select column for amount'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          buildWhen: (prevState, state) {
            return prevState.fields[TransactionField.amount] != state.fields[TransactionField.amount];
          },
          builder: (context, state) {
            final i = state.fields[TransactionField.amount];
            return Text('${i != null ? '\'${state.csvHeaders[i]}\'' : 'No'} column is selected');
          },
        ),
        description: const Text(
          'Select the column where the total value of each transaction is specified.'
          ' Use a point as a decimal separator.',
        ),
        content: _ColumnSelector(field: TransactionField.amount),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.amount] != null,
              builder: (context, isLoaded) {
                return _buildNextButton(enabled: isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.amount] != null,
              builder: (context, isLoaded) {
                return _buildResetButton(
                  enabled: isLoaded,
                  onTap: () => cubit.updateField(TransactionField.amount, null),
                );
              },
            ),
          ];
        },
      ),

      // ~ Quantity
      _Step(
        index: 2,
        title: const Text('Select column for quantity'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            final i = state.fields[TransactionField.quantity];
            return Text('${i != null ? '\'${state.csvHeaders[i]}\'' : 'No'} column is selected');
          },
        ),
        description: const Text(
          'Select the column where the quantities (units) of each transaction is specified.'
          ' Use a point as a decimal separator.',
        ),
        content: _ColumnSelector(field: TransactionField.quantity),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.quantity] != null,
              builder: (context, isLoaded) {
                return _buildNextButton(enabled: isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.amount] != null,
              builder: (context, isLoaded) {
                return _buildResetButton(
                  enabled: isLoaded,
                  onTap: () => cubit.updateField(TransactionField.quantity, null),
                );
              },
            ),
          ];
        },
      ),

      // ~ Account
      _Step(
        index: 3,
        title: const Text('Select column for account'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          buildWhen: (prevState, state) {
            return prevState.fields[TransactionField.account] != state.fields[TransactionField.account];
          },
          builder: (context, state) {
            final i = state.fields[TransactionField.account];
            return Text('${i != null ? '\'${state.csvHeaders[i]}\'' : 'No'} column is selected');
          },
        ),
        description: const Text(
          'Select the column where the account to which each transaction belongs is specified.'
          ' You can also select a default account in case we cannot find the account you want.'
          ' If a default account is not specified, we will create one with the same name.',
        ),
        content: Column(
          spacing: 12.0,
          children: <Widget>[
            _ColumnSelector(field: TransactionField.account),

            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, ImportStatus>(
              selector: (state) => state.importStatus,
              builder: (context, status) {
                return AsyncFormField<InveslyAccount>(
                  enabled: status == ImportStatus.loaded,
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
                        CircleAvatar(foregroundImage: AssetImage(value.avatarSrc), radius: 10.0),
                        Text(value.name, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
                      ],
                    );
                  },
                  trailing: const Icon(Icons.arrow_drop_down_rounded),
                );
              },
            ).withLabel('Default account'),
          ],
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) {
                return state.isCsvLoaded &&
                    state.fields[TransactionField.account] != null &&
                    state.defaultAccount != null;
              },
              builder: (context, isLoaded) {
                return _buildNextButton(enabled: isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.account] != null,
              builder: (context, isLoaded) {
                return _buildResetButton(
                  enabled: isLoaded,
                  onTap: () {
                    cubit.updateField(TransactionField.account, null);
                    cubit.updateDefaultAccount(null);
                  },
                );
              },
            ),
          ];
        },
      ),

      // ~ AMC
      _Step(
        index: 4,
        title: const Text('Select column for AMC'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          buildWhen: (prevState, state) {
            return prevState.fields[TransactionField.amc] != state.fields[TransactionField.amc];
          },
          builder: (context, state) {
            final i = state.fields[TransactionField.amc];
            return Text('${i != null ? '\'${state.csvHeaders[i]}\'' : 'No'} column is selected');
          },
        ),
        description: const Text(
          'Select the column where the account to which each transaction belongs is specified.'
          ' You can also select a default account in case we cannot find the account you want.'
          ' If a default account is not specified, we will create one with the same name.',
        ),
        content: _ColumnSelector(field: TransactionField.amc),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) {
                return state.isCsvLoaded && state.fields[TransactionField.amc] != null && state.defaultAccount != null;
              },
              builder: (context, isLoaded) {
                return _buildNextButton(enabled: isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.amc] != null,
              builder: (context, isLoaded) {
                return _buildResetButton(enabled: isLoaded, onTap: () => cubit.updateField(TransactionField.amc, null));
              },
            ),
          ];
        },
      ),

      // ~ Date
      _Step(
        index: 5,
        title: const Text('Select column for date'),
        subtitle: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          buildWhen: (prevState, state) {
            return prevState.fields[TransactionField.date] != state.fields[TransactionField.date];
          },
          builder: (context, state) {
            final i = state.fields[TransactionField.date];
            return Text('${i != null ? '\'${state.csvHeaders[i]}\'' : 'No'} column is selected');
          },
        ),
        description: const Text(
          'Select the column where the date of each transaction is specified.'
          ' If not specified, transactions will be created with the current date',
        ),
        content: Column(
          spacing: 12.0,
          children: <Widget>[
            _ColumnSelector(field: TransactionField.date),

            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, ImportStatus>(
              selector: (state) => state.importStatus,
              builder: (context, status) {
                return AsyncFormField<String>(
                  enabled: status == ImportStatus.loaded,
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
                );
              },
            ).withLabel('Default date format'),
          ],
        ),
        controlsBuilder: (context, details) {
          return <Widget>[
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) {
                return state.isCsvLoaded &&
                    state.fields[TransactionField.date] != null &&
                    state.defaultDateFormat != null;
              },
              builder: (context, isLoaded) {
                return _buildNextButton(enabled: isLoaded, onTap: details.onStepContinue);
              },
            ),
            BlocSelector<ImportTransactionsCubit, ImportTransactionsState, bool>(
              selector: (state) => state.isCsvLoaded && state.fields[TransactionField.date] != null,
              builder: (context, isLoaded) {
                return _buildResetButton(
                  enabled: isLoaded,
                  onTap: () => cubit.updateField(TransactionField.date, null),
                );
              },
            ),
          ];
        },
      ),

      // ~ Others - Type, Note
      _Step(
        index: 6,
        title: const Text('Select other columns'),
        content: Column(
          spacing: 12.0,
          children: <Widget>[
            // ~ Type
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(padding: EdgeInsets.symmetric(horizontal: 12.0), child: Text('Transaction type')),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Specify the column where the transaction type name is specified.'
                    ' The types can be integer (0 for investment and 1 for redemption or dividend) or'
                    ' can be one character (like I, R, D) or can be string.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                _ColumnSelector(field: TransactionField.type),

                TransactionTypeSelectorFormField(
                  initialValue: cubit.state.defaultType,
                  onChanged: (value) {
                    if (value == null) return;
                    cubit.updateDefaultType(value);
                  },
                ).withLabel('Default transaction type'),
              ],
            ),

            _ColumnSelector(field: TransactionField.notes).withLabel('Notes column'),
          ],
        ),
      ),
    ];

    return Column(
      children: <Widget>[
        Expanded(
          child: Stepper(
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
          ),
        ),

        const InveslyDivider(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
              builder: (context, state) {
                return FilledButton.icon(
                  onPressed: _steps.length - 1 == currentStep
                      ? () {
                          cubit.reviewTransactions();
                          context.push(BlocProvider.value(value: cubit, child: const ReviewTransactionsPage()));
                        }
                      : null,
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Import CSV'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyleButton _buildNextButton({VoidCallback? onTap, bool enabled = true}) {
    return FilledButton.icon(
      onPressed: enabled ? onTap : null,
      icon: const Icon(Icons.check_rounded),
      label: const Text('Next'),
    );
  }

  ButtonStyleButton _buildResetButton({VoidCallback? onTap, bool enabled = true}) {
    return FilledButton.tonalIcon(
      onPressed: enabled ? onTap : null,
      icon: const Icon(Icons.refresh),
      label: const Text('Reset'),
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
  const _ColumnSelector({super.key, required this.field});

  final TransactionField field;

  // List<DropdownMenuEntry<int>> get _entries => [
  //   DropdownMenuEntry(value: null, label: '~~ UNSPECIFIED ~'),
  //   ...allColumns.entries
  //   .whereNot((entry) => columnsToExclude.contains(entry.key))
  //   .map((entry) => DropdownMenuEntry(value: entry.key, label: entry.value)),
  // ];

  Future<int?> _showModal(BuildContext context) async {
    final state = context.read<ImportTransactionsCubit>().state;

    return await showModalBottomSheet<int>(
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
                  child: Text(
                    'Select column for ${field.name}',
                    style: context.textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Section(
                  tiles: state.csvHeaders.asMap().entries.map((entry) {
                    final isSelected = entry.key == state.fields[field];
                    final isSelectionAllowed = !state.fields.values.contains(entry.key) || isSelected;
                    return SectionTile(
                      title: Text(entry.value.trim()),
                      onTap: () => context.pop(entry.key),
                      trailingIcon: isSelected
                          ? const Icon(Icons.check_rounded)
                          : isSelectionAllowed
                          ? null
                          : const Icon(Icons.cancel_rounded),
                      enabled: isSelectionAllowed,
                      selected: isSelected,
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
    final cubit = context.read<ImportTransactionsCubit>();
    return BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
      buildWhen: (prevState, state) {
        return prevState.importStatus != state.importStatus || prevState.fields[field] != state.fields[field];
      },
      builder: (context, state) {
        $logger.i('Rebuilding ColumnSelector for field $field');
        return AsyncFormField<int>(
          enabled: state.importStatus == ImportStatus.loaded,
          initialValue: cubit.state.fields[field],
          onTapCallback: (value) async {
            final columnIndex = await _showModal(context);
            return columnIndex ?? value;
          },
          onChanged: (value) {
            if (value == null) return;
            context.read<ImportTransactionsCubit>().updateField(field, value);
          },
          childBuilder: (value) {
            if (value == null) {
              return Text(
                'Select a column',
                style: TextStyle(color: context.theme.disabledColor),
                overflow: TextOverflow.ellipsis,
              );
            }
            return Text(state.csvHeaders[value], overflow: TextOverflow.ellipsis);
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
