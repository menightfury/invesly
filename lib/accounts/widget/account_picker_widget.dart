import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_page.dart';
import 'package:invesly/accounts/model/account_model.dart';

class AccountPickerWidget extends StatelessWidget {
  const AccountPickerWidget({
    super.key,
    this.accountId,
    this.onPickup,
    this.showAddAccountOption = true,
    this.enabled = true,
    required this.child,
    this.avatar,
    this.side,
    this.color,
  });

  final int? accountId;
  final ValueChanged<InveslyAccount>? onPickup;
  final bool showAddAccountOption;
  final bool enabled;
  final Widget child;
  final Widget? avatar;
  final BorderSide? side;
  final Color? color;

  static Future<InveslyAccount?> showModal(
    BuildContext context, {
    int? accountId,
    bool showAddAccountOption = true,
  }) async {
    return await showModalBottomSheet<InveslyAccount>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return _AccountsList(
          accountId: accountId,
          onPickup: (account) => Navigator.maybePop(context, account),
          showAddAccountOption: showAddAccountOption,
        );
      },
    );
  }

  Future<void> _handlePressed(BuildContext context) async {
    final newAccount = await AccountPickerWidget.showModal(
      context,
      accountId: accountId,
      showAddAccountOption: showAddAccountOption,
    );
    if (newAccount == null) return;
    onPickup?.call(newAccount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DefaultTextStyle(
      style: theme.textTheme.bodyMedium!.copyWith(color: enabled ? null : theme.disabledColor),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      child: child,
    );
    return ActionChip(
      label: label,
      avatar: avatar,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      onPressed: enabled ? () => _handlePressed(context) : null,
      side: side,
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return theme.disabledColor;
        return color;
      }),
    );
  }
}

class _AccountsList extends StatefulWidget {
  const _AccountsList({super.key, this.accountId, this.onPickup, this.showAddAccountOption = true});

  final int? accountId;
  final ValueChanged<InveslyAccount>? onPickup;
  final bool showAddAccountOption;

  @override
  State<_AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<_AccountsList> {
  @override
  void initState() {
    super.initState();
    // Fetch accounts, if not already fetched
    final cubit = context.read<AccountsCubit>();
    if (cubit.state is! AccountsLoadedState) {
      cubit.fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        // spacing: 8.0,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Select an account',
                    style: context.textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (widget.showAddAccountOption)
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add new account',
                    onPressed: () => context.push(const EditAccountPage()),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),

          // ~ Accounts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder<AccountsCubit, AccountsState>(
              builder: (context, state) {
                if (state.isError) {
                  return Text('Error loading accounts', style: TextStyle(color: context.colors.error));
                }

                if (state is AccountsLoadedState) {
                  if (state.accounts.isEmpty) {
                    return const EmptyWidget(label: Text('No accounts found. Please add an account.'));
                  }

                  final accounts = state.accounts;
                  return RadioGroup<int>(
                    groupValue: widget.accountId,
                    onChanged: (value) {
                      if (value == null) return;
                      final account = accounts.firstWhereOrNull((a) => a.id == value);
                      if (account != null) {
                        widget.onPickup?.call(account);
                      }
                    },
                    child: Section(
                      margin: EdgeInsets.zero,
                      tiles: List.generate(accounts.length, (index) {
                        final account = accounts.elementAt(index);
                        return RadioSectionTile<int>(
                          value: account.id,
                          icon: PhysicalModel(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            child: Image.asset(account.avatarSrc),
                          ),
                          title: Text(account.name, overflow: TextOverflow.ellipsis),
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      }),
                    ),
                  );
                }

                return Skeletonizer(
                  child: Section(
                    tiles: List.generate(
                      2,
                      (_) => Skeleton.leaf(child: SectionTile(title: const Text('Loading names ...'))),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
