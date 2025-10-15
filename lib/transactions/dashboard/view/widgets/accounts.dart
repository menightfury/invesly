part of '../dashboard_screen.dart';

class _AccountsList extends StatelessWidget {
  const _AccountsList({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return SizedBox(
      height: 120.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountState) {
              return BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, dashboardState) {
                  final isError = accountState.isError || dashboardState.isError;
                  final isLoading = accountState.isLoading || dashboardState.isLoading;
                  final accounts = accountState.isLoaded ? (accountState as AccountsLoadedState).accounts : null;
                  final totalAmount = dashboardState is DashboardLoadedState
                      ? dashboardState.stats.fold<double>(0, (v, el) => v + el.totalAmount)
                      : null;

                  return Row(
                    spacing: 8.0,
                    children: <Widget>[
                      // ~~~ Accounts ~~~
                      ...List.generate(
                        accounts?.length ?? 1, // dummy count for shimmer effect
                        (index) {
                          final account = accounts?.elementAt(index);

                          return BlocSelector<AppCubit, AppState, bool>(
                            selector: (state) => state.primaryAccountId == account?.id,
                            builder: (context, isCurrentAccount) {
                              $logger.i('rebuilding $account');
                              return Tappable(
                                // onTap: isLoading ? null : () => RouteUtils.pushRoute(
                                //   context,
                                //   AccountDetailsPage(
                                //     account: account,
                                //     accountIconHeroTag: 'dashboard-page__account-icon-${account.id}',
                                //   ),
                                // ),
                                width: 160.0,
                                childAlignment: Alignment.centerLeft,
                                border: BorderSide(color: isCurrentAccount ? context.colors.primary : Colors.black),
                                content: Shimmer(
                                  isLoading: isLoading,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4.0,
                                    children: <Widget>[
                                      account == null
                                          ? Skeleton(color: isError ? context.colors.error : null)
                                          : Text(account.name, overflow: TextOverflow.ellipsis),

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
                                      Spacer(),
                                      Text('5 transactions', style: textTheme.labelMedium),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // ~~~ Add account ~~~
                      Tappable(
                        onTap: () => context.push(const EditAccountScreen()),
                        color: context.colors.secondaryContainer,
                        width: 160.0,
                        border: BorderSide(color: context.colors.onSecondaryContainer, width: 1.0),
                        content: Shimmer(
                          isLoading: isLoading,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4.0,
                            children: <Widget>[
                              isLoading
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Icon(Icons.format_list_bulleted_add, color: context.colors.onSecondaryContainer),
                              isLoading
                                  ? Skeleton(color: isError ? context.colors.error : null)
                                  : Text(
                                      'Create account',
                                      style: TextStyle(color: context.colors.onSecondaryContainer),
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
          ),
        ),
      ),
    );
  }
}
