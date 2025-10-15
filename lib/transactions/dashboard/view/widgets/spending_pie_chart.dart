part of '../dashboard_screen.dart';

class _SpendingPieChart extends StatelessWidget {
  const _SpendingPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: const Text('Categories'),
      icon: const Icon(Icons.pie_chart_rounded),
      tiles: [
        BlocBuilder<AccountsCubit, AccountsState>(
          builder: (context, accountState) {
            return BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, dashboardState) {
                final isError = accountState.isError || dashboardState.isError;
                final isLoading = accountState.isLoading || dashboardState.isLoading;
                final accounts = accountState.isLoaded ? (accountState as AccountsLoadedState).accounts : null;
                if (dashboardState is DashboardLoadedState) {
                  $logger.i(dashboardState.stats);
                }
                // final stats = dashboardState is DashboardLoadedState
                //     ? dashboardState.stats.firstWhereOrNull((stat) => stat.amcGenre == genre)
                //     : null;
                final totalAmount = dashboardState is DashboardLoadedState
                    ? dashboardState.stats.fold<double>(0, (v, el) => v + el.totalAmount)
                    : null;
                return SectionTile(
                  title: SizedBox(
                    height: 256.0,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            centerSpaceRadius: 72.0,
                            sections: [
                              PieChartSectionData(value: 40, color: Colors.green, radius: 40, showTitle: false),
                              PieChartSectionData(value: 42, color: Colors.blue, radius: 40, showTitle: false),
                              PieChartSectionData(value: 8, color: Colors.purple, radius: 40, showTitle: false),
                              PieChartSectionData(value: 3, color: Colors.red, radius: 40, showTitle: false),
                              PieChartSectionData(value: 0, color: Colors.pink, radius: 40, showTitle: false),
                              PieChartSectionData(value: 0, color: Colors.green.shade200, radius: 40, showTitle: false),
                            ],
                            // sections: AmcGenre.values.map((genre) => PieChartSectionData(genre)).toList(),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Total investment'),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12.0,
                      children: AmcGenre.values
                          .map((genre) => _buildLegendItem(context, genre.title, genre.color))
                          .toList(growable: false),
                    ),
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
}
