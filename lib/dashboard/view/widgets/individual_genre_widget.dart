part of '../dashboard_page.dart';

class _IndividualGenreWidget extends StatefulWidget {
  const _IndividualGenreWidget(this.genre, {super.key});

  final AmcGenre genre;

  @override
  State<_IndividualGenreWidget> createState() => _IndividualGenreWidgetState();
}

class _IndividualGenreWidgetState extends State<_IndividualGenreWidget> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: Text(widget.genre.name),
      icon: const Icon(Icons.pie_chart_outline_rounded),
      trailingIcon: GestureDetector(
        onTap: () {
          Navigator.of(context).push(GenreDetailsPage.route(widget.genre));
        },
        child: const Icon(Icons.chevron_right_rounded),
      ),
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
                      ? statState.stats.where((stat) => stat.amc.genre == widget.genre).toList()
                      : null;
                  final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalAmount);
                  stats?.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

                  return Skeletonizer(
                    enabled: isLoading,
                    child: Column(
                      children: <Widget>[
                        // ~ Total amount
                        BlocSelector<AppCubit, AppState, bool>(
                          selector: (state) => state.isPrivateMode,
                          builder: (context, isPrivateMode) {
                            return CurrencyView(
                              amount: totalAmount ?? 0.0,
                              style: textTheme.headlineLarge?.copyWith(
                                color: isError ? context.colors.error : widget.genre.color,
                              ),
                              decimalsStyle: textTheme.headlineSmall?.copyWith(
                                color: isError ? context.colors.error : widget.genre.color,
                              ),
                              currencyStyle: textTheme.bodyMedium?.copyWith(
                                color: isError ? context.colors.error : widget.genre.color,
                              ),
                              privateMode: isPrivateMode,
                              // compactView: snapshot.data! >= 1_00_00_000
                            );
                          },
                        ),

                        // ~ Holdings
                        Text('${stats?.length ?? 0} holdings'),

                        // ~ Top five holdings
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
                              title: stat == null ? Skeleton2() : Text(stat.amc.name, overflow: TextOverflow.ellipsis),
                              subtitle: stats == null
                                  ? Skeleton2(color: isError ? context.colors.error : null)
                                  : Text('${stat?.numTransactions ?? 0} transactions', overflow: TextOverflow.ellipsis),
                              trailingIcon: stats == null
                                  ? Skeleton2(color: isError ? context.colors.error : null)
                                  : BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.isPrivateMode,
                                      builder: (context, isPrivateMode) {
                                        return CurrencyView(
                                          amount: stat?.totalAmount ?? 0,
                                          style: context.textTheme.headlineMedium?.copyWith(
                                            color: isError ? context.colors.error : widget.genre.color,
                                          ),
                                          decimalsStyle: context.textTheme.headlineSmall?.copyWith(
                                            fontSize: 13.0,
                                            color: isError ? context.colors.error : widget.genre.color,
                                          ),
                                          currencyStyle: context.textTheme.bodySmall?.copyWith(
                                            color: isError ? context.colors.error : widget.genre.color,
                                          ),
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
