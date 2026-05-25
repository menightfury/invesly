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
    final chipPadding = const EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 12.0);

    return SizedBox(
      // height: 120.0,
      child: Align(
        alignment: Alignment.centerLeft,
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
                    context.read<AppCubit>().updatePrimaryAccount(accounts.first.id);
                  }
                }
                return BlocSelector<AppCubit, AppState, String?>(
                  selector: (state) => state.primaryAccountId,
                  builder: (context, primaryAccountId) {
                    return Row(
                      spacing: 8.0,
                      children: <Widget>[
                        // ~~~ Accounts ~~~
                        if (accounts.isNotEmpty)
                          ...accounts.map((account) {
                            final isSelected = primaryAccountId == account.id;
                            return ChoiceChip(
                              showCheckmark: false,
                              onSelected: (selected) {
                                // update primary account
                                selected ? context.read<AppCubit>().updatePrimaryAccount(account.id) : null;
                              },
                              labelPadding: chipPadding,
                              selected: isSelected,
                              avatar: CircleAvatar(backgroundImage: AssetImage(account.avatarSrc)),
                              label: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: isSelected ? context.colors.onPrimary : context.colors.primary),
                              ),
                              color: WidgetStateProperty.resolveWith<Color?>((state) {
                                if (state.contains(WidgetState.selected)) return context.colors.primary;

                                return null;
                              }),
                              side: BorderSide(color: context.colors.primary, width: 1.0),
                            );
                          }),

                        // ~~~ Add account ~~~
                        ActionChip(
                          onPressed: () => context.push(const EditAccountPage()),
                          avatar: const Icon(Icons.add_rounded),
                          labelPadding: chipPadding,
                          label: Text('Add account', style: TextStyle(color: context.colors.onSecondaryContainer)),
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
