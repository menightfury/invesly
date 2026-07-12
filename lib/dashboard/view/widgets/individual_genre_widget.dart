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
        onTap: () => context.push(GenreDetailsPage(widget.genre)),
        child: const Icon(Icons.chevron_right_rounded),
      ),
      tiles: <Widget>[
        SectionTile(
          title: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 100.0),
            child: BlocBuilder<StatCubit, StatState>(
              builder: (context, statState) {
                // ~ Error state
                if (statState.isError) {
                  return Center(
                    child: Text('Error fetching data', style: TextStyle(color: context.colors.error)), // TODO: Redesign
                  );
                }

                final isLoading = statState.isInitial || statState.isLoading;
                final stats = statState.isLoaded && statState.stats.isNotEmpty
                    ? statState.stats
                          .where((stat) => stat.amc.genre == widget.genre)
                          .where((stat) => stat.totalQnty > 0)
                          .toList()
                    : null;
                final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalInvested);
                stats?.sort((a, b) => b.totalInvested.compareTo(a.totalInvested));

                return Skeletonizer(
                  enabled: isLoading,
                  child: Column(
                    children: <Widget>[
                      // ~ Total amount
                      isLoading
                          ? Text('Loading...', style: textTheme.displayMedium)
                          : BlocSelector<AppCubit, AppState, bool>(
                              selector: (state) => state.isPrivateMode,
                              builder: (context, isPrivateMode) {
                                return CurrencyView(
                                  amount: totalAmount ?? 0.0,
                                  style: textTheme.headlineLarge?.copyWith(color: widget.genre.color),
                                  decimalsStyle: textTheme.headlineSmall?.copyWith(color: widget.genre.color),
                                  currencyStyle: textTheme.bodyMedium?.copyWith(color: widget.genre.color),
                                  privateMode: isPrivateMode,
                                  // compactView: snapshot.data! >= 1_00_00_000
                                );
                              },
                            ),

                      // ~ Holdings
                      isLoading ? Text('Loading...') : Text('${stats?.length ?? 'No'} holdings'),
                      const Gap(16.0),

                      // ~ Top five holdings
                      _buildHoldingSection(isLoaded: !isLoading, stats: stats),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingSection({bool isLoaded = false, List<InveslyStat>? stats}) {
    if (isLoaded) {
      if (stats == null || stats.isEmpty) {
        return const Center(
          child: EmptyWidget(label: Text('This is so empty.\n Add some transactions to see stats here.')),
        );
      }

      return Section(
        margin: EdgeInsets.zero,
        tiles: List.generate(math.min(stats.length, 5), (i) {
          final stat = stats.elementAt(i);
          return SectionTile(
            tileColor: context.theme.canvasColor.lighten(30),
            title: Text(stat.amc.name, overflow: TextOverflow.ellipsis),
            subtitle: Text('${stat.numTrns} transactions', overflow: TextOverflow.ellipsis),
            secondaryIcon: BlocSelector<AppCubit, AppState, bool>(
              selector: (state) => state.isPrivateMode,
              builder: (context, isPrivateMode) {
                return CurrencyView(
                  amount: stat.totalInvested,
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

    return Section(
      margin: EdgeInsets.zero,

      tiles: List.generate(3, (_) {
        return SectionTile(
          tileColor: context.theme.canvasColor.lighten(30),
          title: Text('Loading...'),
          subtitle: Text('Loading...'),
        );
      }),
    );
  }
}
