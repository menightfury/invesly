import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/import_transactions/cubit/import_transactions_cubit.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_screen.dart';

class ReviewTransactionsPage extends StatelessWidget {
  const ReviewTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportTransactionsCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Review CSV')),
      body: SafeArea(
        child: BlocBuilder<ImportTransactionsCubit, ImportTransactionsState>(
          builder: (context, state) {
            final errors = state.errorInRows;
            final transactions = state.transactionsToInsert;
            $logger.d('=========== Transactions =================== $transactions');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (transactions.isNotEmpty)
                  Expanded(
                    child: Section.builder(
                      tileCount: transactions.length,
                      tileBuilder: (context, index) {
                        final trn = transactions[index];
                        final hasError = errors.containsKey(index);

                        return SectionTile(
                          tileColor: hasError ? context.theme.colorScheme.errorContainer : null,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8.0,
                            children: <Widget>[
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4.0,
                                children: <Widget>[
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Asset Management Company (AMC)',
                                        style: context.textTheme.labelSmall?.copyWith(
                                          color: context.theme.disabledColor,
                                        ),
                                      ),
                                      Text(trn.amc?.name ?? 'Null'),

                                      if (hasError && errors[index]!.contains(TransactionField.amc))
                                        Text(
                                          'Please provide a valid AMC name`',
                                          style: context.textTheme.labelSmall?.copyWith(color: context.colors.error),
                                        ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 4.0,
                                    runSpacing: 2.0,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: context.theme.disabledColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        child: Text(
                                          'Mutual fund',
                                          style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: context.theme.disabledColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        child: Text(
                                          'Equity',
                                          style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: context.theme.disabledColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        child: Text(
                                          'Large cap',
                                          style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: context.theme.disabledColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        child: Text(
                                          'Direct',
                                          style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: context.theme.disabledColor,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        ),
                                        child: Text(
                                          'Growth',
                                          style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Account',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            color: context.theme.disabledColor,
                                          ),
                                        ),
                                        Text(trn.account.name),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Amount',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            color: context.theme.disabledColor,
                                          ),
                                        ),
                                        Text('₹ ${trn.totalAmount.toPrecisionString()}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Date',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            color: context.theme.disabledColor,
                                          ),
                                        ),
                                        Text(trn.investedOn.toReadable()),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Type',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            color: context.theme.disabledColor,
                                          ),
                                        ),
                                        Text(trn.transactionType.name),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Quantity',
                                          style: context.textTheme.labelSmall?.copyWith(
                                            color: context.theme.disabledColor,
                                          ),
                                        ),
                                        Text('${trn.quantity.toPrecisionString()} units'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Note',
                                    style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                  ),
                                  Text(trn.note ?? 'Null', softWrap: true, overflow: TextOverflow.visible),
                                ],
                              ),
                            ],
                          ),
                          subtitle: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              spacing: 8.0,
                              children: <Widget>[
                                ActionChip(
                                  label: const Text('Edit', style: TextStyle(color: Colors.white)),
                                  avatar: const Icon(Icons.edit_rounded, color: Colors.white),
                                  labelStyle: context.textTheme.labelSmall,
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: context.colors.secondary,
                                  side: BorderSide.none,
                                  onPressed: () {
                                    context.push(EditTransactionScreen(initialTransaction: trn));
                                  },
                                ),
                                ActionChip(
                                  label: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  avatar: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                                  labelStyle: context.textTheme.labelSmall,
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: context.colors.error,
                                  side: BorderSide.none,
                                  // color: WidgetStatePropertyAll<Color>(Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                if (transactions.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text('No data available.\nPlease import a valid CSV file', textAlign: TextAlign.center),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: transactions.isEmpty
                          ? () => context.pop()
                          : state.isCsvLoaded
                          ? () async {
                              // showLoadingDialog(
                              //   context,
                              //   () async {
                              //     await cubit.importTransactions();
                              //   },

                              //   onError: (err) {
                              //     if (err is CsvImportException) {
                              //       if (!context.mounted) return;
                              //       _showErrorSheet(context, err.errors);

                              //       // await cubit.importTransactions();
                              //     }
                              //   },
                              // );
                            }
                          : null,
                      icon: transactions.isEmpty ? const Icon(Icons.arrow_back) : const Icon(Icons.upload_file_rounded),
                      label: transactions.isEmpty ? const Text('Return') : const Text('Import CSV'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
