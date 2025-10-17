part of '../dashboard_screen.dart';

class _CategoriesWidget extends StatelessWidget {
  const _CategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: const Text('Categories'),
      icon: const Icon(Icons.pie_chart_rounded),
      // InveslyDivider.dashed(dashWidth: 2.0, thickness: 2.0),
      // tiles: AmcGenre.values.map((genre) => _buildGenre(context, genre)).toList(),
      tiles: [
        BlocSelector<AppCubit, AppState, String?>(
          selector: (state) => state.primaryAccountId,
          builder: (context, accountId) {
            return BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, dashboardState) {
                final isError = dashboardState.isError;
                final isLoading = dashboardState.isLoading;
                if (dashboardState is DashboardLoadedState) {
                  $logger.i(dashboardState.stats);
                }
                // final stats = dashboardState is DashboardLoadedState
                //     ? dashboardState.stats.firstWhereOrNull((stat) => stat.amcGenre == genre)
                //     : null;
                final stats = dashboardState is DashboardLoadedState
                    ? dashboardState.stats.where((stat) => stat.accountId == accountId).toList()
                    : null;
                final totalAmount = stats?.fold<double>(0, (v, el) => v + el.totalAmount);
                return SectionTile(
                  title: Column(
                    children: <Widget>[
                      Text('Total investment', style: context.textTheme.bodySmall),
                      totalAmount == null
                          ? Skeleton(color: isError ? context.colors.error : null)
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

                      // ~ Pie chart
                      SizedBox(
                        height: 256.0,
                        child: stats == null
                            ? Skeleton(color: isError ? context.colors.error : null)
                            : _SpendingPieChart(stats),
                      ),
                      // Center(
                      //   child: Wrap(
                      //     alignment: WrapAlignment.center,
                      //     spacing: 12.0,
                      //     children: AmcGenre.values
                      //         .map((genre) => _buildLegendItem(context, genre.title, genre.color))
                      //         .toList(growable: false),
                      //   ),
                      // ),
                      Section(
                        margin: null,
                        tiles: List.generate(AmcGenre.values.length, (i) {
                          final genre = AmcGenre.getByIndex(i);
                          final stat = stats?.singleWhereOrNull((stat) => stat.amcGenre == genre);

                          return SectionTile(
                            tileColor: Colors.white.withAlpha(100),
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(genre.icon, color: genre.color),
                                AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  child: SizedBox.square(
                                    dimension: 40.0,
                                    child: AnimatedCircularProgress(
                                      // rotationOffsetPercent: percentage,
                                      rotationOffsetPercent: 0,
                                      // percent: ui.clampDouble(percent / 100, 0, 1),
                                      percent: ui.clampDouble(30 / 100, 0, 1),
                                      // backgroundColor: progressBackgroundColor,
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(genre.title, overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              '${stat?.numTransactions ?? 0} transactions',
                              style: context.textTheme.labelSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                              selector: (state) => state.isPrivateMode,
                              builder: (context, isPrivateMode) {
                                return CurrencyView(
                                  amount: stat?.totalAmount ?? 0.0,
                                  integerStyle: context.textTheme.headlineMedium?.copyWith(color: genre.color),
                                  decimalsStyle: context.textTheme.headlineSmall?.copyWith(
                                    fontSize: 13.0,
                                    color: genre.color,
                                  ),
                                  currencyStyle: context.textTheme.bodySmall,
                                  privateMode: isPrivateMode,
                                );
                              },
                            ),
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
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.0,
      children: <Widget>[
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: context.textTheme.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildGenre(BuildContext context, AmcGenre genre) {
    return SectionTile(
      onTap: () {},
      borderRadius: BorderRadius.zero,
      title: Stack(
        children: <Widget>[
          Positioned(
            right: -12.0,
            top: -12.0,
            child: Icon(genre.icon, size: 64.0, color: context.colors.secondary.withAlpha(50)),
          ),
          BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountState) {
              return BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, dashboardState) {
                  final isError = accountState.isError || dashboardState.isError;
                  final isLoading = accountState.isLoading || dashboardState.isLoading;
                  final accounts = accountState.isLoaded ? (accountState as AccountsLoadedState).accounts : null;
                  final stats = dashboardState is DashboardLoadedState
                      ? dashboardState.stats.firstWhereOrNull((stat) => stat.amcGenre == genre)
                      : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12.0,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: Text(genre.title, overflow: TextOverflow.ellipsis)),
                          isLoading
                              ? Skeleton()
                              : BlocSelector<AppCubit, AppState, bool>(
                                  selector: (state) => state.isPrivateMode,
                                  builder: (context, isPrivateMode) {
                                    return CurrencyView(
                                      amount: stats?.totalAmount ?? 0.0,
                                      integerStyle: context.textTheme.headlineMedium,
                                      decimalsStyle: context.textTheme.headlineSmall?.copyWith(fontSize: 13.0),
                                      currencyStyle: context.textTheme.bodySmall,
                                      privateMode: isPrivateMode,
                                    );
                                  },
                                ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
