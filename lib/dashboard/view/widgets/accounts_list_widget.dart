part of '../dashboard_page.dart';

class _AccountsList extends StatefulWidget {
  const _AccountsList({super.key});

  @override
  State<_AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<_AccountsList> {
  InveslyAccount? primaryAccount;

  @override
  void initState() {
    super.initState();
    // Fetch accounts, if not already fetched
    final cubit = context.read<AccountsCubit>();
    if (!cubit.state.isLoaded) {
      cubit.fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();
    const cardPadding = EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 12.0);
    const cardConstraint = BoxConstraints(minWidth: 184.0, minHeight: 120.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: cardConstraint.minHeight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountState) {
              // ~ Error state
              if (accountState.isError) {
                return SimpleCard(
                  label: Text('Failed to load accounts', style: TextStyle(color: context.colors.error)),
                  padding: cardPadding,
                  color: context.colors.errorContainer,
                );
              }

              // ~ Loaded state
              if (accountState is AccountsLoadedState) {
                final accounts = accountState.accounts;
                if (accounts.isNotEmpty) {
                  if (appCubit.state.primaryAccountId != null) {
                    primaryAccount = accounts.firstWhereOrNull(
                      (account) => account.id == appCubit.state.primaryAccountId,
                    );
                  }
                  // If primary account is not set, set first account as primary account
                  if (primaryAccount == null) {
                    appCubit.updatePrimaryAccount(accounts.first.id);
                  }
                }
                return BlocSelector<AppCubit, AppState, int?>(
                  selector: (state) => state.primaryAccountId,
                  builder: (context, primaryAccountId) {
                    return Row(
                      spacing: 8.0,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // ~~~ Accounts ~~~
                        if (accounts.isNotEmpty)
                          ...accounts.map((account) {
                            final isSelected = primaryAccountId == account.id;
                            return GestureDetector(
                              onTap: isSelected ? null : () => appCubit.updatePrimaryAccount(account.id),
                              behavior: HitTestBehavior.opaque,
                              child: IntrinsicWidth(
                                child: SimpleCard(
                                  padding: cardPadding,
                                  constraints: cardConstraint,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: iCardBorderRadius,
                                    side: isSelected
                                        ? BorderSide(width: 2.0, color: context.colors.primary)
                                        : BorderSide.none,
                                  ),
                                  elevation: isSelected ? 2.0 : 0.0,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 12.0,
                                    children: <Widget>[
                                      SizedBox.square(
                                        dimension: 40.0,
                                        child: PhysicalModel(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          child: Image.asset(account.avatarSrc),
                                        ),
                                      ),
                                      Text(
                                        account.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.headlineSmall?.copyWith(color: context.colors.primary),
                                      ),
                                    ],
                                  ),
                                  child: BlocBuilder<StatCubit, StatState>(
                                    builder: (context, statState) {
                                      if (statState.isError) {
                                        return Text(
                                          'Error loading amount',
                                          style: TextStyle(color: context.colors.error),
                                        );
                                      }

                                      if (statState.isLoaded) {
                                        final amount = statState.getTotalInvested(accountId: account.id);
                                        return CurrencyView(amount: amount, style: context.textTheme.headlineLarge);
                                      }

                                      return LoadingAnimationWidget.newtonCradle(
                                        color: context.colors.primary,
                                        size: 56.0,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),

                        // ~~~ Add account ~~~
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push(const EditAccountPage()),
                          child: SimpleCard(
                            constraints: cardConstraint,
                            padding: cardPadding,
                            shape: RoundedRectangleBorder(
                              borderRadius: iCardBorderRadius,
                              side: BorderSide(width: 2.0, color: context.theme.disabledColor.lighten(80)),
                            ),
                            color: context.colors.surface,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4.0,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox.square(
                                  dimension: 40.0,
                                  child: PhysicalModel(
                                    color: context.theme.disabledColor.lighten(50),
                                    shape: BoxShape.circle,
                                    child: SizedBox.square(
                                      dimension: 40.0,
                                      child: Icon(Icons.add_rounded, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Add account',
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodyMedium?.copyWith(color: context.theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              return Skeletonizer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8.0,
                  children: List.generate(2, (_) {
                    return const Skeleton.leaf(
                      child: SimpleCard(
                        label: Text('Loading accounts...'),
                        padding: cardPadding,
                        constraints: cardConstraint,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
