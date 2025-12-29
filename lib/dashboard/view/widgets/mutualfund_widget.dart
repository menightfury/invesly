part of '../dashboard_screen.dart';

class _MutualFundWidget extends StatefulWidget {
  const _MutualFundWidget({this.status = _InitializationStatus.initializing, super.key});

  final _InitializationStatus status;

  @override
  State<_MutualFundWidget> createState() => _MutualFundWidgetState();
}

class _MutualFundWidgetState extends State<_MutualFundWidget> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Section(
      title: const Text('Mutual Funds'),
      icon: const Icon(Icons.pie_chart_outline_rounded),
      tiles: <Widget>[
        SectionTile(
          title: BlocBuilder<TransactionStatCubit, TransactionStatState>(
            builder: (context, statState) {
              final isLoading = widget.status.isInitializing || statState.isLoading;
              final isError = widget.status.isError || statState.isError;

              return Shimmer(
                isLoading: isLoading,
                child: BlocSelector<AppCubit, AppState, String?>(
                  selector: (state) => state.primaryAccountId,
                  builder: (context, accountId) {
                    final stats = widget.status.isInitialized && statState is TransactionStatLoadedState
                        ? statState.stats.where((stat) => stat.accountId == accountId).toList()
                        : null;
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

                        // // ~ Pie chart
                        // SizedBox(
                        //   height: 224.0,
                        //   child: stats == null
                        //       ? Skeleton(color: isError ? context.colors.error : null)
                        //       : ValueListenableBuilder(
                        //           valueListenable: _selectedCategory,
                        //           builder: (context, selectedCategory, _) {
                        //             return _SpendingPieChart(
                        //               stats,
                        //               selectedGenre: _selectedCategory.value,
                        //               onSelected: (genre) {
                        //                 _selectedCategory.value = genre;
                        //               },
                        //             );
                        //           },
                        //         ),
                        // ),

                        // ~ Genres
                        Section(
                          margin: EdgeInsets.zero,
                          tiles: List.generate(AmcGenre.values.length, (i) {
                            final genre = AmcGenre.fromIndex(i);
                            final isSelected = true;
                            final stat = stats?.singleWhereOrNull((stat) => stat.amcGenre == genre);

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
                                      '${stat?.numTransactions ?? 0} transactions',
                                      style: TextStyle(color: isSelected ? Colors.white : null),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              trailingIcon: stats == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.isPrivateMode,
                                      builder: (context, isPrivateMode) {
                                        return CurrencyView(
                                          amount: stat?.totalAmount ?? 0,
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
                              onTap: () {},
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
