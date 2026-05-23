import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_page.dart';
import 'package:invesly/accounts/model/account_model.dart';

class InveslyAccountPickerWidget extends StatefulWidget {
  const InveslyAccountPickerWidget({super.key, this.accountId, this.onPickup, this.showAddAccountOption = true});

  final String? accountId;
  final ValueChanged<InveslyAccount>? onPickup;
  final bool showAddAccountOption;

  static Future<InveslyAccount?> showModal(
    BuildContext context, {
    String? accountId,
    bool showAddAccountOption = true,
  }) async {
    return await showModalBottomSheet<InveslyAccount>(
      context: context,
      // isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return InveslyAccountPickerWidget(
          accountId: accountId,
          onPickup: (account) => Navigator.maybePop(context, account),
          showAddAccountOption: showAddAccountOption,
        );
      },
    );
  }

  @override
  State<InveslyAccountPickerWidget> createState() => _InveslyAccountPickerWidgetState();
}

class _InveslyAccountPickerWidgetState extends State<InveslyAccountPickerWidget> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<AccountsCubit>();
    if (cubit.state is! AccountsLoadedState) {
      cubit.fetchAccounts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
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
                        style: TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.showAddAccountOption)
                      // IconButton(
                      //   leading: const Icon(Icons.add_reaction_rounded),
                      //   title: const Text('Add new account'),
                      //   onTap: () => context.push(const EditAccountPage()),
                      // ),
                  ],
                ),
              ),

              _buildAccountList(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountList(AccountsState state) {
    final isLoading = state.isLoading;

    if (state.isError) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text('Error loading accounts', style: TextStyle(color: Colors.red)),
      );
    }

    if (state.isLoaded && (state as AccountsLoadedState).accounts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text('No accounts found. Please add an account.', style: TextStyle(color: Colors.grey)),
      );
    }

    final accounts = state.isLoaded ? (state as AccountsLoadedState).accounts : null;
    return Skeletonizer(
      enabled: isLoading,
      child: Column(
        children: [
          ...List.generate(
            accounts?.length ?? 2, // dummy count for shimmer effect
            (index) {
              final account = accounts?.elementAt(index);

              return ListTile(
                leading: PhysicalModel(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  child: account != null ? Image.asset(account.avatarSrc) : null,
                ),
                title: Text(account?.name ?? 'Loading...', overflow: TextOverflow.ellipsis),
                trailing: account?.id == widget.accountId ? const Icon(Icons.check_rounded) : null,
                onTap: account != null ? () => widget.onPickup?.call(account) : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
