import 'dart:async';

import 'package:invesly/amcs/model/amc_model.dart';
import 'package:invesly/transactions/edit_transaction/edit_transaction_screen.dart';

import 'package:invesly/transactions/model/transaction_model.dart';
import 'package:invesly/amcs/model/amc_repository.dart';
import 'package:invesly/common_libs.dart';

class AmcOverviewScreen extends StatefulWidget {
  const AmcOverviewScreen(this.id, {super.key});

  final String id;

  @override
  State<AmcOverviewScreen> createState() => _AmcOverviewScreenState();
}

class _AmcOverviewScreenState extends State<AmcOverviewScreen> {
  late final Future<InveslyAmc?> amcFuture;

  @override
  void initState() {
    super.initState();
    amcFuture = context.read<AmcRepository>().getAmc(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: FutureBuilder<InveslyAmc?>(
          future: amcFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const PMErrorWidget();
              }

              final amc = snapshot.data;
              if (amc == null) {
                return const EmptyWidget(height: 160.0, label: 'Amc not found!');
              }

              // final tags = [amc.plan, amc.sector, amc.subSector].whereNotNull().toList(growable: false);
              final tags = amc.tags?.toList() ?? <String>[];

              return Stack(
                children: <Widget>[
                  ListView(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                    children: <Widget>[
                      // ~ Name
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(amc.name, style: textTheme.headlineSmall, maxLines: 2),
                      ),
                      const SizedBox(height: 16.0),

                      // ~ Tags
                      SizedBox(
                        height: 24.0,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          separatorBuilder: (_, _) => const SizedBox(width: 8.0),
                          itemBuilder: (context, i) {
                            final tag = tags[i];
                            return Center(
                              child: Material(
                                color: const Color.fromARGB(255, 105, 5, 151),
                                shape: const StadiumBorder(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                  child: Text(
                                    tag,
                                    style: textTheme.labelMedium?.copyWith(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: tags.length,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // ~ Transaction
                      _TransactionList(amc.id),
                    ],
                  ),

                  // ~ Add transaction button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(const EditTransactionScreen()),
                        icon: const Icon(Icons.add),
                        label: const Text('Add transaction'),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _TransactionList extends StatefulWidget {
  const _TransactionList(this.amcId, {super.key});

  final String amcId;

  @override
  State<_TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<_TransactionList> {
  late final Future<List<InveslyTransaction>> invsFuture;

  @override
  void initState() {
    super.initState();
    // final currentAccount = context.read<SettingsCubit>().state.currentAccount;
    // if (currentAccount != null) {
    //   invsFuture = context.read<TransactionRepository>().getTransactions(currentAccount.id, amcId: widget.amcId);
    // } else {
    //   invsFuture = Future.value([]);
    // }
    invsFuture = Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InveslyTransaction>>(
      future: invsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const PMErrorWidget();
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const EmptyWidget(height: 160.0, label: 'No transactions have been found!');
          }

          return ColumnBuilder(
            itemBuilder: (context, index) {
              final transaction = data[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {},
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_rounded,
                      // label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (context) => context.push(EditTransactionScreen(initialTransaction: transaction)),
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      icon: Icons.edit_note_rounded,
                      // label: 'Edit',
                    ),
                  ],
                ),
                child: ListTile(
                  leading:
                      transaction.quantity > 0
                          ? const Icon(Icons.arrow_upward_rounded)
                          : const Icon(Icons.arrow_downward_rounded),
                  title: Text(transaction.investedOn.toReadable()),
                  subtitle: Text('${transaction.quantity} units @ Rs. ${transaction.totalAmount}'),
                  trailing: Text(
                    (transaction.quantity * transaction.totalAmount).toStringAsFixed(2),
                    style: const TextStyle(fontSize: 24.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
              );
            },
            separatorBuilder: (_, _) => const InveslyDivider(indent: 8.0, colors: [Colors.black12]),
            itemCount: data.length,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
