part of '../dashboard_screen.dart';

class _AmcGenresStat extends StatelessWidget {
  const _AmcGenresStat({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: const Text('Categories'),
      icon: const Icon(Icons.swap_vert_rounded),
      // InveslyDivider.dashed(dashWidth: 2.0, thickness: 2.0),
      tiles: AmcGenre.values.map((genre) => _buildGenre(context, genre)).toList(),
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
                      Section(
                        margin: null,
                        tiles: List.generate(
                          accounts?.length ?? 1, // dummy for shimmer effect
                          (index) {
                            final account = accounts?.elementAt(index);

                            return SectionTile(
                              tileColor: Colors.white,
                              title: account == null
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Text(account.name, overflow: TextOverflow.ellipsis),
                              subtitle: isLoading
                                  ? Skeleton()
                                  : Text(
                                      '${stats?.numTransactions ?? 0} transactions',
                                      style: context.textTheme.labelSmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              trailingIcon: isLoading
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
                            );
                          },
                        ),
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
