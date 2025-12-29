part of '../dashboard_screen.dart';

class _GenreSummariesWidget extends StatefulWidget {
  const _GenreSummariesWidget(this.status, {super.key});

  final _InitializationStatus status;

  @override
  State<_GenreSummariesWidget> createState() => _GenreSummariesWidgetState();
}

class _GenreSummariesWidgetState extends State<_GenreSummariesWidget> {
  late final ValueNotifier<AmcGenre?> _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = ValueNotifier<AmcGenre?>(null);
  }

  @override
  Widget build(BuildContext context) {
    return Section(
      title: const Text('Total Investment'),
      icon: const Icon(Icons.pie_chart_rounded),
      // InveslyDivider.dashed(dashWidth: 2.0, thickness: 2.0),
      // trailingIcon: const Icon(Icons.chevron_right)
      tiles: [
        widget.status.isInitialized
            ? _buildTile(context)
            : _buildLoadingOrErrorState(context, isError: widget.status.isError),
      ],
    );
  }

  Widget _buildLoadingOrErrorState(BuildContext context, {bool isError = false}) {
    return SectionTile(
      title: Shimmer(
        isLoading: !isError,
        child: Column(
          children: <Widget>[
            // ~ Total amount
            Skeleton(color: isError ? context.colors.error : null, height: 24.0),

            // ~ Pie chart
            SizedBox(height: 224.0, child: Skeleton(color: isError ? context.colors.error : null)),

            // ~ Genres
            Section(
              // margin: null,
              tiles: List.generate(AmcGenre.values.length, (i) {
                final genre = AmcGenre.fromIndex(i);
                return SectionTile(
                  tileColor: Colors.white.withAlpha(100),
                  icon: CircleAvatar(
                    backgroundColor: genre.color.lighten(70),
                    child: Icon(genre.icon, color: genre.color),
                  ),
                  title: Text(genre.title, overflow: TextOverflow.ellipsis),
                  subtitle: Skeleton(color: isError ? context.colors.error : null),
                  trailingIcon: Skeleton(color: isError ? context.colors.error : null),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tractionRepo = context.read<TransactionRepository>();

    return SectionTile(
      title: StreamBuilder(
        stream: tractionRepo.onDataChanged.asyncMap((event) => tractionRepo.getTransactionStats()),
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final isError = snapshot.hasError;

          return Shimmer(
            isLoading: isLoading,
            child: BlocSelector<AppCubit, AppState, String?>(
              selector: (state) => state.primaryAccountId,
              builder: (context, accountId) {
                final stats = snapshot.data?.where((stat) => stat.accountId == accountId).toList();
                final totalAmount = stats?.fold<double>(0, (v, el) => v + el.totalAmount);
                return Column(
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

                    // ~ Genres
                    ValueListenableBuilder(
                      valueListenable: _selectedCategory,
                      builder: (context, selectedCategory, _) {
                        return Section(
                          // margin: null,
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
                              subtitle: stat == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Text(
                                      '${stat.numTransactions ?? 0} transactions',
                                      style: TextStyle(color: isSelected ? Colors.white : null),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              trailingIcon: stat == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.isPrivateMode,
                                      builder: (context, isPrivateMode) {
                                        return CurrencyView(
                                          amount: stat.totalAmount,
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
