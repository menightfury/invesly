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

            if (accountsState.isLoaded && (trnState.isInitial || !trnState.hasTransactions)) {
              tiles = <Widget>[
                SectionTile(
                  title: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')),
                ),
              ];
            } else if (trnState.isError || trnState.transactions == null) {
              tiles = <Widget>[
                SectionTile(title: Text(trnState.errorMsg ?? 'Some error has been occurred! Please try again later.')),
              ];
            } else if (trnState.isLoaded) {
              final rts = trnState.transactions!;
              if (rts.isEmpty) {
                tiles = <Widget>[
                  SectionTile(
                    title: Center(child: Text('Oops! This is so empty', style: context.textTheme.titleLarge)),
                    subtitle: Center(
                      child: Text(
                        'No transactions have been found for this month.\nAdd a few transactions.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    contentSpacing: 12.0,
                  ),
                ];
              } else {
                tiles = rts.map((rt) {
                  return SectionTile(
                    icon: Icon(rt.transactionType.icon),
                    title: Text(rt.amc?.name ?? 'NULL', style: context.textTheme.bodyMedium),
                    subtitle: Text(rt.investedOn.toReadable()),
                    trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isPrivateMode,
                      builder: (context, isPrivateMode) {
                        return CurrencyView(
                          amount: rt.totalAmount,
                          integerStyle: context.textTheme.headlineSmall?.copyWith(
                            color: rt.transactionType.color(context),
                          ),
                          privateMode: isPrivateMode,
                        );
                      },
                    ),
                    // onTap: () {},
                  );
                }).toList();
              }
            } else {
              tiles = <Widget>[SectionTile(title: CircularProgressIndicator())];
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
