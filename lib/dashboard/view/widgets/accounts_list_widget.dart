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
    const chipPadding = EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 12.0);
    const constraint = BoxConstraints(minWidth: 184.0, minHeight: 120.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: constraint.minHeight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: BlocBuilder<AccountsCubit, AccountsState>(
            builder: (context, accountState) {
              if (accountState.isError) {
                return Chip(
                  label: Text('Failed to load accounts', style: TextStyle(color: context.colors.error)),
                  labelPadding: chipPadding,
                  backgroundColor: context.colors.errorContainer,
                );
              }

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
                      // crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // ~~~ Accounts ~~~
                        if (accounts.isNotEmpty)
                          ...accounts.map((account) {
                            final isSelected = primaryAccountId == account.id;
                            // return ChoiceChip(
                            //   showCheckmark: false,
                            //   onSelected: (selected) {
                            //     // update primary account
                            //     selected ? appCubit.updatePrimaryAccount(account.id) : null;
                            //   },
                            //   labelPadding: chipPadding,
                            //   selected: isSelected,
                            //   avatar: CircleAvatar(backgroundImage: AssetImage(account.avatarSrc)),
                            //   label: Text(
                            //     account.name,
                            //     overflow: TextOverflow.ellipsis,
                            //     style: TextStyle(color: isSelected ? context.colors.onPrimary : context.colors.primary),
                            //   ),
                            //   color: WidgetStateProperty.resolveWith<Color?>((state) {
                            //     if (state.contains(WidgetState.selected)) return context.colors.primary;

                            //     return null;
                            //   }),
                            //   side: BorderSide(color: context.colors.primary, width: 1.0),
                            // );
                            return GestureDetector(
                              onTap: isSelected ? null : () => appCubit.updatePrimaryAccount(account.id),
                              behavior: HitTestBehavior.opaque,
                              child: SimpleCard(
                                // clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: iCardBorderRadius,
                                  side: isSelected
                                      ? BorderSide(width: 2.0, color: context.colors.primary)
                                      : BorderSide.none,
                                ),
                                elevation: isSelected ? 2.0 : 0.0,
                                child: ConstrainedBox(
                                  constraints: constraint,
                                  child: Padding(
                                    padding: chipPadding,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 16.0,
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
                                              style: context.textTheme.titleMedium?.copyWith(
                                                color: context.colors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CurrencyView(amount: 5_000.00, style: context.textTheme.headlineLarge),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                        // ~~~ Add account ~~~
                        // ActionChip(
                        //   onPressed: () => context.push(const EditAccountPage()),
                        //   avatar: PhysicalModel(
                        //     color: context.colors.primary,
                        //     shape: BoxShape.circle,
                        //     child: SizedBox.square(
                        //       dimension: 40.0,
                        //       child: Icon(Icons.add_rounded, color: context.colors.onPrimary),
                        //     ),
                        //   ),
                        //   labelPadding: chipPadding,
                        //   label: Text('Add account', style: TextStyle(color: context.colors.onSecondaryContainer)),
                        // ),
                        Material(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: iCardBorderRadius,
                            side: BorderSide(width: 2.0, color: context.theme.disabledColor.lighten(50)),
                          ),
                          color: context.colors.surface,
                          child: InkWell(
                            onTap: () => context.push(const EditAccountPage()),
                            child: ConstrainedBox(
                              constraints: constraint,
                              child: Padding(
                                padding: chipPadding,
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
                                      style: context.textTheme.titleMedium?.copyWith(
                                        color: context.theme.disabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }

              return Skeletonizer(
                child: Section(
                  tiles: List.generate(2, (_) {
                    return Skeleton.leaf(
                      child: Chip(label: const Text('Loading accounts...'), labelPadding: chipPadding),
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
