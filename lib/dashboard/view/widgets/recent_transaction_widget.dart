part of '../dashboard_screen.dart';

class _RecentTransactions extends StatefulWidget {
  const _RecentTransactions({super.key});

  @override
  State<_RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<_RecentTransactions> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, accountsState) {
        return BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, trnState) {
            late final List<Widget> tiles;
            if (accountsState.isError || trnState.isError) {
              tiles = <Widget>[
                SectionTile(title: Text(trnState.errorMsg ?? 'Some error has been occurred! Please try again later.')),
              ];
            } else if (accountsState.isLoaded && trnState.isLoaded) {
              if ((accountsState as AccountsLoadedState).accounts.isNotEmpty &&
                  (trnState.transactions?.isNotEmpty ?? false)) {
                tiles = trnState.transactions!.map((trn) {
                  return SectionTile(
                    icon: Icon(trn.transactionType.icon),
                    title: Text(trn.amc?.name ?? 'NULL', style: context.textTheme.bodyMedium),
                    subtitle: Text(trn.investedOn.toReadable()),
                    trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isPrivateMode,
                      builder: (context, isPrivateMode) {
                        return CurrencyView(
                          amount: trn.totalAmount,
                          integerStyle: context.textTheme.headlineSmall?.copyWith(
                            color: trn.transactionType.color(context),
                          ),
                          privateMode: isPrivateMode,
                        );
                      },
                    ),
                    // onTap: () {},
                  );
                }).toList();
              } else {
                tiles = <Widget>[
                  SectionTile(
                    title: const EmptyWidget(label: Text('This is so empty.\n Add some transactions to see here.')),
                  ),
                ];
              }
            } else {
              tiles = List.generate(5, (index) {
                return Skeletonizer(child: SectionTile(title: Text('Loading...')));
              });
            }

            return Column(
              children: <Widget>[
                Section(
                  title: const Text('Recent Transactions'),
                  // subTitle: Text('From ${period.start.toReadable()} to ${period.end.toReadable()}'),
                  icon: const Icon(Icons.swap_vert_rounded),
                  tiles: tiles,
                ),
                if (trnState.isLoaded && trnState.transactions!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FilledButton.tonalIcon(
                      onPressed: () => context.push(const TransactionsPage()),
                      label: const Icon(Icons.arrow_forward),
                      icon: const Text('See all transactions'),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
