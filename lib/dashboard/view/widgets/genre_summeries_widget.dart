part of '../dashboard_page.dart';

class _GenreSummariesWidget extends StatefulWidget {
  const _GenreSummariesWidget({super.key});

  @override
  State<_GenreSummariesWidget> createState() => _GenreSummariesWidgetState();
}

class _GenreSummariesWidgetState extends State<_GenreSummariesWidget> {
  late final ValueNotifier<AmcGenre?> _selectedGenre;

  @override
  void initState() {
    super.initState();
    _selectedGenre = ValueNotifier<AmcGenre?>(null);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numRows = (AmcGenre.values.length / 2).ceil();

    return Section(
      title: const Text('Net worth'),
      icon: const Icon(Icons.trending_up),
      tiles: <Widget>[
        SectionTile(
          title: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountsState) {
              return BlocBuilder<StatCubit, StatState>(
                builder: (context, statState) {
                  final isError = accountsState.isError || statState.isError;
                  final isLoading = !isError && (accountsState.isLoading || statState.isLoading);
                  final stats = accountsState.isNotEmpty && statState.isLoaded && statState.stats.isNotEmpty
                      ? statState.stats.where((stat) => stat.totalQnty > 0).toList()
                      : null;
                  final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalInvested);

                  return Skeletonizer(
                    enabled: isLoading,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // ~ Total amount
                        BlocSelector<AppCubit, AppState, bool>(
                          selector: (state) => state.isPrivateMode,
                          builder: (context, isPrivateMode) {
                            return CurrencyView(
                              amount: totalAmount ?? 0.0,
                              style: textTheme.displayMedium,
                              decimalsStyle: textTheme.headlineSmall,
                              currencyStyle: textTheme.displaySmall,
                              privateMode: isPrivateMode,
                              // compactView: snapshot.data! >= 1_00_00_000
                            );
                          },
                        ),

                        // ~ Pie chart
                        SizedBox(
                          height: 224.0,
                          child: _buildPieChartSection(
                            state: isError
                                ? _DashboardState.error
                                : isLoading
                                ? _DashboardState.loading
                                : _DashboardState.loaded,
                            stats: stats,
                          ),
                        ),

                        // ~ Genres - Two column layout
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8.0,
                          children: List.generate(numRows, (i) {
                            return Row(
                              spacing: 8.0,
                              children: List.generate(2, (j) {
                                final genre = AmcGenre.fromIndex(2 * i + j);

                                final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
                                final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalInvested);
                                final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTrns);
                                final holdingCount = filteredStats?.length;
                                return Expanded(
                                  child: _buildGenreTile(
                                    genre: genre,
                                    state: isError
                                        ? _DashboardState.error
                                        : isLoading
                                        ? _DashboardState.loading
                                        : _DashboardState.loaded,
                                    numTransactions: numTransactions,
                                    holdingCount: holdingCount,
                                    totalAmount: totalAmount,
                                  ),
                                );
                              }),
                            );
                          }),
                        ),

                        // Section(
                        //   margin: EdgeInsets.zero,
                        //   tiles: List.generate(AmcGenre.values.length, (i) {
                        //     final genre = AmcGenre.fromIndex(i);

                        //     final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
                        //     final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalInvested);
                        //     final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTrns);
                        //     final holdingCount = filteredStats?.length;

                        //     return _buildGenreTile(
                        //       genre: genre,
                        //       state: isError ? _DashboardState.error : isLoading
                        //           ? _DashboardState.loading
                        //           : _DashboardState.loaded,
                        //       numTransactions: numTransactions,
                        //       holdingCount: holdingCount,
                        //       totalAmount: totalAmount,
                        //     );
                        //   }),
                        // );
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

  Widget _buildPieChartSection({required _DashboardState state, List<InveslyStat>? stats}) {
    if (state == _DashboardState.error) {
      return Center(
        child: Text('Error fetching data', style: TextStyle(color: context.colors.error)),
      );
    }

    if (state == _DashboardState.loading) {
      return const Center(child: Text('Loading...'));
    }

    if (stats == null || stats.isEmpty) {
      return Center(child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')));
    }

    return ValueListenableBuilder(
      valueListenable: _selectedGenre,
      builder: (context, selectedGenre, _) {
        return _SpendingPieChart(
          stats,
          selectedGenre: selectedGenre,
          onSelected: (genre) => _selectedGenre.value = genre,
        );
      },
    );
  }

  Widget _buildGenreTile({
    required AmcGenre genre,
    required _DashboardState state,
    int? numTransactions,
    int? holdingCount,
    double? totalAmount,
  }) {
    final isError = state == _DashboardState.error;

    return ValueListenableBuilder(
      valueListenable: _selectedGenre,
      builder: (context, selectedGenre, child) {
        final isSelected = selectedGenre == genre;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: SimpleCard(
            color: isSelected ? genre.color : Colors.white.withAlpha(100),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            elevation: isSelected ? 4.0 : 0.0,
            contentSpacing: 16.0,
            label: Skeleton.keep(
              child: Stack(
                children: <Widget>[
                  // ~ Icon
                  Align(
                    alignment: Alignment.topRight,
                    child: PhysicalModel(
                      color: genre.color.lighten(80),
                      shape: BoxShape.circle,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(genre.icon, color: genre.color.lighten(40)),
                      ),
                    ),
                  ),

                  // ~ Label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    // spacing: 2.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        genre.title,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.headlineSmall?.copyWith(color: isSelected ? Colors.white : null),
                      ),
                      Text(
                        isError
                            ? 'Error fetching data'
                            : state == _DashboardState.loaded
                            ? '${holdingCount ?? 'No'} holdings'
                            : 'Loading...', // Will be replaced by shimmer when loading
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: isError
                              ? context.colors.error
                              : isSelected
                              ? Colors.white
                              : context.colors.secondary,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            child: BlocSelector<AppCubit, AppState, bool>(
              selector: (state) => state.isPrivateMode,
              builder: (context, isPrivateMode) {
                return CurrencyView(
                  amount: totalAmount ?? 0.0,
                  style: context.textTheme.headlineLarge?.copyWith(
                    color: isError
                        ? context.colors.error
                        : isSelected
                        ? Colors.white
                        : genre.color,
                  ),
                  decimalsStyle: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 13.0,
                    color: isError
                        ? context.colors.error
                        : isSelected
                        ? Colors.white
                        : genre.color,
                  ),
                  currencyStyle: context.textTheme.bodySmall,
                  privateMode: isPrivateMode,
                );
              },
            ),
          ),
          onTap: () {
            if (_selectedGenre.value == genre) {
              context.push(GenreDetailsPage(genre));
            } else {
              _selectedGenre.value = genre;
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _selectedGenre.dispose();
    super.dispose();
  }
}
