import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/import_transactions/cubit/import_transactions_cubit.dart';

class ReviewTransactionsPage extends StatelessWidget {
  const ReviewTransactionsPage({super.key});

  final Map<int, List<TransactionField>> errors = const {};

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ImportTransactionsCubit>();
    final csvRows = cubit.state.csvData;

    return Scaffold(
      appBar: AppBar(title: const Text('Review CSV')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
              child: Text(
                'Errors have been found in the following rows',
                style: context.textTheme.labelLarge?.copyWith(color: context.colors.error),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Section.builder(
                tileCount: csvRows.isNotEmpty ? csvRows.length : 1, // 1 to show no data
                tileBuilder: (context, index) {
                  final row = csvRows[index];
                  return SectionTile(
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
                                  style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                ),
                                Text(r'ow[cubit.state.fields[TransactionField.amc]!] as String?'),
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
                                    style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                  ),
                                  Text('Satyajyoti Biswas'),
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
                                    style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                  ),
                                  Text('₹ 5,000.00'),
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
                                    style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                  ),
                                  Text('05 Sep, 2025'),
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
                                    style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                  ),
                                  Text('Invested'),
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
                                    style: context.textTheme.labelSmall?.copyWith(color: context.theme.disabledColor),
                                  ),
                                  Text('10.52 units'),
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
                            Text(
                              'Lorem ipsum doler mat umar quot balchi Lorem ipsum doler mat umar quot balchi Lorem ipsum doler mat umar quot balchi',
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
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
                            label: const Text('Edit'),
                            avatar: const Icon(Icons.edit_rounded),
                            labelStyle: context.textTheme.labelSmall,
                            visualDensity: VisualDensity.compact,
                          ),
                          ActionChip(
                            label: const Text('Delete'),
                            avatar: const Icon(Icons.delete_outline_rounded),
                            labelStyle: context.textTheme.labelSmall,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // ColumnBuilder(
            //   spacing: 12.0,
            //   itemBuilder: (context, index) {
            //     final errorEntry = errors.entries.elementAt(index);
            //     // return ListTile(title: Text('Row number ${errorEntry.key + 1}'));
            //     return Section(
            //       title: Text('Row number ${errorEntry.key + 1}'),
            //       trailingIcon: Icon(Icons.delete_outline_rounded),
            //       tiles: errorEntry.value.map((errorField) {
            //         return SectionTile(
            //           title: Text(errorField.name),

            //           subtitle: SingleChildScrollView(
            //             scrollDirection: Axis.horizontal,
            //             child: Row(
            //               spacing: 8.0,
            //               children: <Widget>[
            //                 ActionChip(
            //                   label: Text('Ignore'),
            //                   avatar: const Icon(Icons.remove_circle_outline_rounded),
            //                   labelStyle: context.textTheme.labelSmall,
            //                   visualDensity: VisualDensity.compact,
            //                 ),
            //                 ActionChip(
            //                   label: Text('Add AMC to Database'),
            //                   avatar: const Icon(Icons.add_rounded),
            //                   labelStyle: context.textTheme.labelSmall,
            //                   visualDensity: VisualDensity.compact,
            //                 ),
            //                 ActionChip(
            //                   label: Text('Select AMC from Database'),
            //                   avatar: const Icon(Icons.edit_rounded),
            //                   labelStyle: context.textTheme.labelSmall,
            //                   visualDensity: VisualDensity.compact,
            //                 ),
            //               ],
            //             ),
            //           ),
            //         );
            //       }).toList(),
            //     );
            //   },
            //   itemCount: errors.length,
            // ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
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
                  },
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Import CSV'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
