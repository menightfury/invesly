part of '../dashboard_screen.dart';

class _RecentTransactions extends StatefulWidget {
  const _RecentTransactions(this.status, {super.key});

  final _InitializationStatus status;

  @override
  State<_RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<_RecentTransactions> {
  late final DateTimeRange<DateTime> period;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfYear = DateTime(now.year, 1, 1);
    // final endOfMonth = DateTime(now.year, now.month + 1, 0);
    period = DateTimeRange(start: startOfYear, end: now);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppCubit, AppState, String?>(
      selector: (state) => state.primaryAccountId,
      builder: (context, accountId) {
        // fetch recent transactions
        context.read<TransactionsCubit>().fetchTransactions(dateRange: period, accountId: accountId, limit: 5);

        return BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            late final List<Widget> tiles;
            if (state.isError || state.transactions == null) {
              tiles = [
                SectionTile(title: Text(state.errorMsg ?? 'Some error has been occurred! Please try again later.')),
              ];
            } else if (state.isLoaded) {
              final rts = state.transactions!;
              if (rts.isEmpty) {
                tiles = [
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
                    onTap: () {},
                  );
                }).toList();
              }
            } else {
              tiles = [SectionTile(title: CircularProgressIndicator())];
            }

            return Column(
              children: <Widget>[
                Section(
                  title: const Text('Recent Transactions'),
                  subTitle: Text('From ${period.start.toReadable()} to ${period.end.toReadable()}'),
                  icon: const Icon(Icons.swap_vert_rounded),
                  tiles: tiles,
                ),
                if (state.isLoaded && state.transactions!.isNotEmpty)
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
