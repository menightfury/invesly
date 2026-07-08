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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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

                        // ~ Genres
                        ValueListenableBuilder(
                          valueListenable: _selectedGenre,
                          builder: (context, _, _) {
                            final numRows = (AmcGenre.values.length / 2).ceil();
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(numRows, (i) {
                                final genre = AmcGenre.fromIndex(i);

                                // final stat = stats?.singleWhereOrNull((stat) => stat.amc == genre);
                                final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
                                final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalInvested);
                                final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTrns);
                                final holdingCount = filteredStats?.length;

                                return Row(
                                  children: <Widget>[
                                    Expanded(
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
                                    ),
                                    Expanded(
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
                                    ),
                                  ],
                                );
                              }),
                            );

                            return GridView.builder(
                              // TODO: Remove GridView and Convert to Multi column Builder
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final genre = AmcGenre.fromIndex(index);

                                // final stat = stats?.singleWhereOrNull((stat) => stat.amc == genre);
                                final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
                                final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalInvested);
                                final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTrns);
                                final holdingCount = filteredStats?.length;

                                return _buildGenreTile(
                                  genre: genre,
                                  state: isError
                                      ? _DashboardState.error
                                      : isLoading
                                      ? _DashboardState.loading
                                      : _DashboardState.loaded,
                                  numTransactions: numTransactions,
                                  holdingCount: holdingCount,
                                  totalAmount: totalAmount,
                                );
                              },
                              itemCount: AmcGenre.values.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                            );
                            // return Section(
                            //   margin: EdgeInsets.zero,
                            //   tiles: List.generate(AmcGenre.values.length, (i) {
                            //     final genre = AmcGenre.fromIndex(i);

                            //     // final stat = stats?.singleWhereOrNull((stat) => stat.amc == genre);
                            //     final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
                            //     final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalInvested);
                            //     final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTrns);
                            //     final holdingCount = filteredStats?.length;

                            //     return _buildGenreTile(
                            //       genre: genre,
                            //       state: isError
                            //           ? _DashboardState.error
                            //           : isLoading
                            //           ? _DashboardState.loading
                            //           : _DashboardState.loaded,
                            //       numTransactions: numTransactions,
                            //       holdingCount: holdingCount,
                            //       totalAmount: totalAmount,
                            //     );
                            //   }),
                            // );
                          },
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

  Widget _buildGenreTile({
    required AmcGenre genre,
    required _DashboardState state,
    int? numTransactions,
    int? holdingCount,
    double? totalAmount,
  }) {
    final isSelected = _selectedGenre.value == genre;
    final isError = state == _DashboardState.error;

    late final Widget subtitle;
    if (isError) {
      subtitle = Text(
        'Error fetching data',
        style: TextStyle(color: context.colors.error, overflow: TextOverflow.ellipsis),
      );
    } else if (state == _DashboardState.loaded) {
      subtitle = Text(
        // '${numTransactions ?? 'No'} transactions',
        '${holdingCount ?? 'No'} holdings',
        style: TextStyle(color: isSelected ? Colors.white : null),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      subtitle = const Text(
        'Loading...', // Will be replaced by shimmer when loading
        overflow: TextOverflow.ellipsis,
      );
    }

    return SimpleCard(
      color: isSelected ? genre.color : Colors.white.withAlpha(100),
      label: Skeleton.keep(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.0,
          children: <Widget>[
            PhysicalModel(
              color: genre.color.lighten(60),
              shape: BoxShape.circle,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(genre.icon, color: genre.color),
              ),
            ),
            Skeleton.keep(
              child: Text(
                genre.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isSelected ? Colors.white : null),
              ),
            ),
          ],
        ),
      ),
      // subtitle: subtitle,
      child: BlocSelector<AppCubit, AppState, bool>(
        selector: (state) => state.isPrivateMode,
        builder: (context, isPrivateMode) {
          return CurrencyView(
            amount: totalAmount ?? 0.0,
            style: context.textTheme.headlineMedium?.copyWith(
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
      // onTap: () {
      //   if (_selectedGenre.value == genre) {
      //     context.push(GenreDetailsPage(genre));
      //   } else {
      //     _selectedGenre.value = genre;
      //   }
      // },
    );
  }
}
