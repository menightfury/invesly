part of '../dashboard_page.dart';

class _GenreSummariesWidget extends StatefulWidget {
  const _GenreSummariesWidget({super.key});

  @override
  State<_GenreSummariesWidget> createState() => _GenreSummariesWidgetState();
}

class _GenreSummariesWidgetState extends State<_GenreSummariesWidget> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final numRows = (AmcGenre.values.length / 2).ceil();

    return Section(
      title: const Text('Net worth'),
      icon: const Icon(Icons.trending_up),
      tiles: <Widget>[
        SectionTile(
          title: BlocBuilder<StatCubit, StatState>(
            builder: (context, statState) {
              // ~ Error state
              if (statState.isError) {
                return SizedBox(
                  height: 250.0, // TODO: Redesign
                  child: Center(
                    child: Text('Error fetching data', style: TextStyle(color: context.colors.error)),
                  ),
                );
              }

              // final isLoading = statState.isInitial || statState.isLoading;
              final isLoading = true;
              final stats = statState.isLoaded && statState.stats.isNotEmpty
                  ? statState.stats.where((stat) => stat.totalQnty > 0).toList()
                  : null;
              final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalInvested);

              return Skeletonizer(
                enabled: isLoading,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // ~ Total amount
                    isLoading
                        ? Text('Loading...', style: textTheme.displayMedium)
                        : BlocSelector<AppCubit, AppState, bool>(
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
                      child: isLoading
                          ? Bone.circle(size: 176.0)
                          : _buildPieChartSection(context: context, stats: stats),
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
                            return Expanded(
                              child: isLoading
                                  ? Bone(height: 100.0)
                                  : _buildGenreTile(context: context, genre: genre, stats: stats),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartSection({required BuildContext context, List<InveslyStat>? stats}) {
    final cubit = context.read<DashboardCubit>();

    if (stats == null || stats.isEmpty) {
      return Center(child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')));
    }

    return BlocSelector<DashboardCubit, DashboardState, AmcGenre?>(
      selector: (state) => state.selectedGenre,
      builder: (context, selectedGenre) {
        return _SpendingPieChart(
          stats,
          selectedGenre: selectedGenre,
          onSelected: (genre) => cubit.updateSelectedGenre(genre),
        );
      },
    );
  }

  Widget _buildGenreTile({required BuildContext context, required AmcGenre genre, List<InveslyStat>? stats}) {
    final cubit = context.read<DashboardCubit>();

    final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
    final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalInvested);
    // final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTrns);
    final holdingCount = filteredStats?.length;

    return BlocSelector<DashboardCubit, DashboardState, bool>(
      selector: (state) => state.selectedGenre == genre,
      builder: (context, isSelected) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: SimpleCard(
            color: isSelected ? genre.color : context.theme.canvasColor.lighten(30),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            elevation: isSelected ? 2.0 : 0.0,
            contentSpacing: 16.0,
            label: Stack(
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
                      '${holdingCount ?? 'No'} holdings',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: isSelected ? Colors.white : context.colors.secondary,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            child: BlocSelector<AppCubit, AppState, bool>(
              selector: (state) => state.isPrivateMode,
              builder: (context, isPrivateMode) {
                return CurrencyView(
                  amount: totalAmount ?? 0.0,
                  style: context.textTheme.headlineLarge?.copyWith(color: isSelected ? Colors.white : genre.color),
                  decimalsStyle: context.textTheme.headlineSmall?.copyWith(
                    fontSize: 13.0,
                    color: isSelected ? Colors.white : genre.color,
                  ),
                  currencyStyle: context.textTheme.bodySmall,
                  privateMode: isPrivateMode,
                );
              },
            ),
          ),
          onTap: () {
            if (cubit.state.selectedGenre == genre) {
              context.push(GenreDetailsPage(genre));
            } else {
              cubit.updateSelectedGenre(genre);
            }
          },
        );
      },
    );
  }
}
