part of '../dashboard_screen.dart';

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions(this.transactions, {this.period, super.key});

  final DateTimeRange? period;
  final List<InveslyTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        late final List<Widget> tiles;
        if (state.isLoaded) {
          final rts = (state as DashboardLoadedState).recentTransactions;
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
                      integerStyle: context.textTheme.headlineSmall?.copyWith(color: rt.transactionType.color(context)),
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
              subTitle: period != null ? Text('From ${period.start.toReadable()} to ${period.end.toReadable()}') :,
              icon: const Icon(Icons.swap_vert_rounded),
              tiles: tiles,
            ),
            if (state is DashboardLoadedState && state.recentTransactions.isNotEmpty)
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
  }
}
