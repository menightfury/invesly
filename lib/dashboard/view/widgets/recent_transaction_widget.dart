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
            } else if ((accountsState.isLoaded && (accountsState as AccountsLoadedState).accounts.isEmpty) ||
                (trnState.isLoaded && (trnState.transactions?.isEmpty ?? true))) {
              tiles = <Widget>[
                SectionTile(
                  title: const EmptyWidget(label: Text('This is so empty.\n Add some transactions to see here.')),
                ),
              ];
            } else if (accountsState.isLoaded &&
                (accountsState as AccountsLoadedState).accounts.isNotEmpty &&
                trnState.isLoaded &&
                (trnState.transactions?.isNotEmpty ?? false)) {
              tiles = trnState.transactions!.map((trn) {
                return SectionTile(
                  icon: Icon(trn.transactionType.icon),
                  title: Text(trn.amc?.name ?? 'NULL', style: context.textTheme.bodyMedium),
                  subtitle: FormattedDate(date: trn.investedOn),
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
              tiles = List.generate(5, (index) {
                return SectionTile(
                  icon: Icon(Icons.swap_vert_rounded),
                  title: Text('Loading...', style: context.textTheme.bodyMedium),
                  subtitle: Text('Loading...'),
                  trailingIcon: CurrencyView(amount: 0.0, integerStyle: context.textTheme.headlineSmall),
                );
              });
            }

            return Column(
              children: <Widget>[
                Skeletonizer(
                  enabled: accountsState.isLoading || trnState.isLoading,
                  child: Section(
                    title: const Skeleton.keep(child: Text('Recent Transactions')),
                    // subTitle: Text('From ${period.start.toReadable()} to ${period.end.toReadable()}'),
                    icon: const Skeleton.keep(child: Icon(Icons.swap_vert_rounded)),
                    tiles: tiles,
                  ),
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
