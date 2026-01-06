part of '../dashboard_screen.dart';

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

    return Section(
      title: const Text('Investment Summary'),
      icon: const Icon(Icons.pie_chart_rounded),
      tiles: <Widget>[
        SectionTile(
          title: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountsState) {
              return BlocBuilder<TransactionStatCubit, TransactionStatState>(
                builder: (context, statState) {
                  final isError = accountsState.isError || statState.isError;
                  final isLoading = accountsState.isLoading && statState.isLoading;
                  final stats = accountsState.isEmpty
                      ? <TransactionStat>[]
                      : statState is TransactionStatLoadedState
                      ? statState.stats
                      : null;
                  final totalAmount = stats?.fold<double>(0.0, (v, el) => v + el.totalAmount);
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

                        // ~ Pie chart
                        SizedBox(
                          height: 224.0,
                          child: stats == null
                              ? Skeleton(color: isError ? context.colors.error : null)
                              : ValueListenableBuilder(
                                  valueListenable: _selectedGenre,
                                  builder: (context, selectedCategory, _) {
                                    return _SpendingPieChart(
                                      stats,
                                      selectedGenre: _selectedGenre.value,
                                      onSelected: (genre) {
                                        _selectedGenre.value = genre;
                                      },
                                    );
                                  },
                                ),
                        ),

                        // ~ Genres
                        ValueListenableBuilder(
                          valueListenable: _selectedGenre,
                          builder: (context, selectedGenre, _) {
                            return Section(
                              margin: EdgeInsets.zero,
                              tiles: List.generate(AmcGenre.values.length, (i) {
                                final genre = AmcGenre.fromIndex(i);
                                final isSelected = selectedGenre == genre;
                                // final stat = stats?.singleWhereOrNull((stat) => stat.amc == genre);
                                final filteredStats = stats?.where((stat) => stat.amc.genre == genre);
                                final totalAmount = filteredStats?.fold<double>(0, (v, el) => v + el.totalAmount);
                                final numTransactions = filteredStats?.fold<int>(0, (v, el) => v + el.numTransactions);

                                return SectionTile(
                                  tileColor: isSelected ? genre.color : Colors.white.withAlpha(100),
                                  icon: isLoading
                                      ? Skeleton()
                                      : CircleAvatar(
                                          backgroundColor: genre.color.lighten(70),
                                          child: Icon(genre.icon, color: genre.color),
                                        ),
                                  title: isLoading
                                      ? Skeleton()
                                      : Text(
                                          genre.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: isSelected ? Colors.white : null),
                                        ),
                                  subtitle: stats == null
                                      ? Skeleton(color: isError ? context.colors.error : null)
                                      : Text(
                                          '${numTransactions ?? 0} transactions',
                                          style: TextStyle(color: isSelected ? Colors.white : null),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  trailingIcon: stats == null
                                      ? Skeleton(color: isError ? context.colors.error : null)
                                      : BlocSelector<AppCubit, AppState, bool>(
                                          selector: (state) => state.isPrivateMode,
                                          builder: (context, isPrivateMode) {
                                            return CurrencyView(
                                              amount: totalAmount ?? 0.0,
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
                                  onTap: () => _selectedGenre.value = genre,
                                );
                              }),
                            );
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
}
