// ignore_for_file: unused_element

import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/common_libs.dart';

class RecentTransactionsWidget extends StatefulWidget {
  const RecentTransactionsWidget(this.transactions, {super.key});

  final List<InveslyTransaction> transactions;

  @override
  State<RecentTransactionsWidget> createState() => _RecentTransactionsWidgetState();
}

class _RecentTransactionsWidgetState extends State<RecentTransactionsWidget> {
  @override
  void initState() {
    super.initState();
    // final bla =
    //     List<String?>.generate(widget.investments.length, (index) => widget.investments[index].amcId, growable: false)
    //         .toSet()
    //         .toList();
    // $logger.d(bla);
    // Supabase.instance.client.from('amcs').select().inFilter('id', bla).then($logger.f);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (widget.transactions.isEmpty) return const Center(child: Text('No transactions are found.'));

    return ColumnBuilder(
      itemBuilder: (context, index) {
        final inv = widget.transactions[index];

        return Material(
          borderRadius: BorderRadius.circular(8.0),
          child: ListTile(
            leading: const Icon(Icons.face_2),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // inv.amcId ?? 'NULL',
                  'NULL',
                  style: textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                //! TODO: For testing purpose only. Delete in production mode
                Text(
                  inv.userId,
                  style: const TextStyle(fontSize: 12.0, color: Colors.redAccent),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            subtitle: Text(inv.investedOn.toReadable(), style: textTheme.labelMedium),
            trailing: Text(
              inv.totalAmount.toPrecision(2).toString(),
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(fontSize: 32.0),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8.0),
      itemCount: widget.transactions.length,
    );
  }
}
