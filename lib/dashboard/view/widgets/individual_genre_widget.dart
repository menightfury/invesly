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
      title: Text(widget.genre.title),
      icon: const Icon(Icons.pie_chart_outline_rounded),
      trailingIcon: GestureDetector(
        onTap: () {
          Navigator.of(context).push(GenreDetailsPage.route(widget.genre));
        },
        child: const Icon(Icons.chevron_right_rounded),
      ),
      tiles: <Widget>[
        SectionTile(
          title: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100.0),
            child: BlocBuilder<AccountsCubit, AccountsState>(
              builder: (context, accountsState) {
                return BlocBuilder<TransactionStatCubit, TransactionStatState>(
                  builder: (context, statState) {
                    final isError = accountsState.isError || statState.isError;
                    final isLoading = !isError && (accountsState.isLoading || statState.isLoading);
                    final stats = accountsState.isNotEmpty && statState is TransactionStatLoadedState
                        ? statState.stats
                              .where((stat) => stat.amc.genre == widget.genre)
                              .where((stat) => stat.totalQuantity > 0)
                              .toList()
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
                          Text('${stats?.length ?? 'No'} holdings'),
                          Gap(16.0),

                          // ~ Top five holdings
                          _buildHoldingSection(
                            state: isError
                                ? _DashboardState.error
                                : isLoading
                                ? _DashboardState.loading
                                : _DashboardState.loaded,
                            stats: stats,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingSection({required _DashboardState state, List<AmcStat>? stats}) {
    if (state == _DashboardState.error) {
      return Center(
        child: Text('Error fetching data', style: TextStyle(color: context.colors.error)),
      );
    }

    if (state == _DashboardState.loading) {
      return Center(
        child: Text(
          'Loading...', // Will be replaced by shimmer skeleton when loading
        ),
      );
    }

    if (state == _DashboardState.loaded && (stats == null || stats.isEmpty)) {
      return Center(child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')));
    }

    return Section(
      margin: EdgeInsets.zero,
      tiles: List.generate(math.min(stats?.length ?? 3, 5), (i) {
        // 3 for dummy skeleton tiles
        final stat = stats?.elementAt(i);

        return SectionTile(
          tileColor: Colors.white.withAlpha(100),
          title: Text(stat?.amc.name ?? 'Loading...', overflow: TextOverflow.ellipsis),
          subtitle: Text('${stat?.numTransactions ?? 0} transactions', overflow: TextOverflow.ellipsis),
          trailingIcon: BlocSelector<AppCubit, AppState, bool>(
            selector: (state) => state.isPrivateMode,
            builder: (context, isPrivateMode) {
              return CurrencyView(
                amount: stat?.totalAmount ?? 0.0,
                style: context.textTheme.headlineMedium?.copyWith(color: widget.genre.color),
                decimalsStyle: context.textTheme.headlineSmall?.copyWith(fontSize: 13.0, color: widget.genre.color),
                currencyStyle: context.textTheme.bodySmall?.copyWith(color: widget.genre.color),
                privateMode: isPrivateMode,
              );
            },
          ),
          // onTap: () {},
        );
      }),
    );
  }
}
