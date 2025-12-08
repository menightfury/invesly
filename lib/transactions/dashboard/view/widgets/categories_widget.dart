part of '../dashboard_screen.dart';

class _CategoriesWidget extends StatefulWidget {
  const _CategoriesWidget({super.key});

  @override
  State<_CategoriesWidget> createState() => _CategoriesWidgetState();
}

class _CategoriesWidgetState extends State<_CategoriesWidget> {
  late final ValueNotifier<AmcGenre?> _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = ValueNotifier<AmcGenre?>(null);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, accountsState) {
        return BlocSelector<AppCubit, AppState, String?>(
          selector: (state) => state.primaryAccountId,
          builder: (context, accountId) {
            return BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, dashboardState) {
                final isError = dashboardState.isError || accountsState.isError;
                final isLoading = dashboardState.isLoading || accountsState.isLoading;
                final stats = dashboardState is DashboardLoadedState
                    ? dashboardState.stats.where((stat) => stat.accountId == accountId).toList()
                    : null;
                final totalAmount = stats?.fold<double>(0, (v, el) => v + el.totalAmount);
                return Section(
                  title: const Text('Total Investment'),
                  icon: const Icon(Icons.pie_chart_rounded),
                  // InveslyDivider.dashed(dashWidth: 2.0, thickness: 2.0),
                  // tiles: AmcGenre.values.map((genre) => _buildGenre(context, genre)).toList(),
                  trailingIcon: Shimmer(
                    isLoading: isLoading,
                    child: totalAmount == null || isLoading
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
                  ),
                  tiles: [
                    SectionTile(
                      title: Shimmer(
                        isLoading: isLoading,
                        child: Column(
                          children: <Widget>[
                            // ~ Pie chart
                            SizedBox(
                              height: 256.0,
                              child: stats == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : ValueListenableBuilder(
                                      valueListenable: _selectedCategory,
                                      builder: (context, selectedCategory, _) {
                                        return _SpendingPieChart(
                                          stats,
                                          selectedGenre: _selectedCategory.value,
                                          onSelected: (genre) {
                                            _selectedCategory.value = genre;
                                          },
                                        );
                                      },
                                    ),
                            ),

                            // ~ Categories
                            ValueListenableBuilder(
                              valueListenable: _selectedCategory,
                              builder: (context, selectedCategory, _) {
                                return Section(
                                  margin: null,
                                  tiles: List.generate(AmcGenre.values.length, (i) {
                                    final genre = AmcGenre.fromIndex(i);
                                    final isSelected = selectedCategory == genre;
                                    final stat = stats?.singleWhereOrNull((stat) => stat.amcGenre == genre);

                                    return SectionTile(
                                      tileColor: isSelected ? genre.color : Colors.white.withAlpha(100),
                                      icon: CircleAvatar(
                                        backgroundColor: genre.color.lighten(70),
                                        child: Icon(genre.icon, color: genre.color),
                                      ),
                                      title: Text(
                                        genre.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: isSelected ? Colors.white : null),
                                      ),
                                      subtitle: Text(
                                        '${stat?.numTransactions ?? 0} transactions',
                                        style: TextStyle(color: isSelected ? Colors.white : null),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailingIcon: BlocSelector<AppCubit, AppState, bool>(
                                        selector: (state) => state.isPrivateMode,
                                        builder: (context, isPrivateMode) {
                                          return CurrencyView(
                                            amount: stat?.totalAmount ?? 0.0,
                                            integerStyle: context.textTheme.headlineMedium?.copyWith(
                                              color: isSelected ? Colors.white : genre.color,
                                            ),
                                            decimalsStyle: context.textTheme.headlineSmall?.copyWith(
                                              fontSize: 13.0,
                                              color: isSelected ? Colors.white : genre.color,
                                            ),
                                            currencyStyle: context.textTheme.bodySmall,
                                            privateMode: isPrivateMode,
                                          );
                                        },
                                      ),
                                      onTap: () => _selectedCategory.value = genre,
                                    );
                                  }),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
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
