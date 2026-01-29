part of '../dashboard_page.dart';

class _AccountsList extends StatefulWidget {
  const _AccountsList({super.key});

  @override
  State<_AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<_AccountsList> {
  @override
  void initState() {
    super.initState();
    // Fetch accounts
    final cubit = context.read<AccountsCubit>();
    if (!cubit.state.isLoaded) {
      cubit.fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appCubit = context.read<AppCubit>();

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
              final isError = accountState.isError;
              final isLoading = accountState.isLoading;
              final accounts = accountState.isLoaded ? (accountState as AccountsLoadedState).accounts : null;
              // If primary account is not set, set first account as primary account
              if (accounts?.isNotEmpty ?? false) {
                final primaryAccount = accounts?.firstWhereOrNull(
                  (account) => account.id == appCubit.state.primaryAccountId,
                );
                if (primaryAccount == null) {
                  context.read<AppCubit>().updatePrimaryAccount(accounts!.first.id);
                }
              }
              return Row(
                spacing: 8.0,
                children: <Widget>[
                  // ~~~ Accounts ~~~
                  ...List.generate(
                    accounts?.length ?? 2, // dummy count for shimmer effect
                    (index) {
                      final account = accounts?.elementAt(index);
                      return Shimmer(
                        isLoading: isLoading,
                        child: account == null
                            ? Skeleton2(
                                color: isError ? context.colors.error : null,
                                width: 160.0,
                                height: 56.0,
                                shape: StadiumBorder(),
                              )
                            : BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.primaryAccountId == account.id,
                                builder: (context, isCurrentAccount) {
                                  $logger.i('rebuilding $account');
                                  return ChoiceChip(
                                    showCheckmark: false,
                                    onSelected: (selected) {
                                      // update primary account
                                      selected ? context.read<AppCubit>().updatePrimaryAccount(account.id) : null;
                                    },
                                    labelPadding: EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 12.0),
                                    selected: isCurrentAccount,
                                    avatar: CircleAvatar(backgroundImage: AssetImage(account.avatarSrc)),
                                    label: Text(
                                      account.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isCurrentAccount ? context.colors.onPrimary : context.colors.primary,
                                      ),
                                    ),
                                    color: WidgetStateProperty.resolveWith<Color?>((state) {
                                      if (state.contains(WidgetState.selected)) return context.colors.primary;

                                      return null;
                                    }),
                                    side: BorderSide(color: context.colors.primary, width: 1.0),
                                  );
                                },
                              ),
                      );
                    },
                  ),

                  // ~~~ Add account ~~~
                  Shimmer(
                    isLoading: isLoading,
                    child: isLoading
                        ? Skeleton2(
                            color: isError ? context.colors.error : null,
                            width: 160.0,
                            height: 50.0,
                            shape: StadiumBorder(),
                          )
                        : ActionChip(
                            onPressed: () => context.push(const EditAccountPage()),
                            avatar: CircleAvatar(
                              backgroundColor: context.colors.primary,
                              child: Icon(Icons.add_rounded, color: context.colors.onPrimary),
                            ),
                            labelPadding: EdgeInsetsGeometry.symmetric(horizontal: 16.0, vertical: 12.0),
                            label: Text('Add account', style: TextStyle(color: context.colors.onSecondaryContainer)),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
