part of '../dashboard_screen.dart';

class _MutualFundWidget extends StatefulWidget {
  const _MutualFundWidget({super.key});

  @override
  State<_MutualFundWidget> createState() => _MutualFundWidgetState();
}

class _MutualFundWidgetState extends State<_MutualFundWidget> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: const Text('Mutual Funds'),
      icon: const Icon(Icons.pie_chart_outline_rounded),
      tiles: <Widget>[
        SectionTile(
          title: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountsState) {
              return BlocBuilder<TransactionStatCubit, TransactionStatState>(
                builder: (context, statState) {
                  if (accountsState.isLoaded && (statState.isInitial || statState.isEmpty)) {
                    return EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.'));
                  }

                  final isError = accountsState.isError || statState.isError;
                  final isLoading = !isError && (accountsState.isLoading || statState.isLoading);
                  final stats = accountsState.isEmpty
                      ? <TransactionStat>[]
                      : statState is TransactionStatLoadedState
                      ? statState.stats.where((stat) => stat.amc.genre == AmcGenre.mf).toList()
                      : null;
                  final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalAmount);
                  stats?.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

                  return Shimmer(
                    isLoading: isLoading,
                    child: Column(
                      children: <Widget>[
                        // ~ Total amount
                        totalAmount == null
                            ? Skeleton(color: isError ? context.colors.error : null, height: 24.0)
                            : BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.isPrivateMode,
                                builder: (context, isPrivateMode) {
                                  return CurrencyView(
                                    amount: totalAmount,
                                    integerStyle: textTheme.headlineLarge,
                                    decimalsStyle: textTheme.headlineSmall,
                                    currencyStyle: textTheme.bodyMedium,
                                    privateMode: isPrivateMode,
                                    // compactView: snapshot.data! >= 1_00_00_000
                                  );
                                },
                              ),

                        // ~ Holdings
                        stats == null
                            ? Skeleton(color: isError ? context.colors.error : null, height: 20.0)
                            : Text('${stats.length} holdings'),

                        // ~ Top three holdings
                        Section(
                          margin: EdgeInsets.zero,
                          tiles: List.generate(math.min(stats?.length ?? 0, 5), (i) {
                            final stat = stats?.elementAt(i);

                            return SectionTile(
                              tileColor: Colors.white.withAlpha(100),
                              // icon: isLoading
                              //     ? Skeleton()
                              //     : CircleAvatar(
                              //         backgroundColor: genre.color.lighten(70),
                              //         child: Icon(genre.icon, color: genre.color),
                              //       ),
                              title: stat == null ? Skeleton() : Text(stat.amc.name, overflow: TextOverflow.ellipsis),
                              subtitle: stats == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Text('${stat?.numTransactions ?? 0} transactions', overflow: TextOverflow.ellipsis),
                              trailingIcon: stats == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.isPrivateMode,
                                      builder: (context, isPrivateMode) {
                                        return CurrencyView(
                                          amount: stat?.totalAmount ?? 0,
                                          integerStyle: context.textTheme.headlineMedium?.copyWith(color: Colors.blue),
                                          decimalsStyle: context.textTheme.headlineSmall?.copyWith(
                                            fontSize: 13.0,
                                            color: Colors.blue,
                                          ),
                                          currencyStyle: context.textTheme.bodySmall,
                                          privateMode: isPrivateMode,
                                        );
                                      },
                                    ),
                              // onTap: () {},
                            );
                          }),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
