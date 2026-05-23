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

          _buildAccountList(context),
        ],
      ),
    );
  }

  Widget _buildAccountList(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        if (state.isError) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Error loading accounts', style: TextStyle(color: Colors.red)),
          );
        }

        if (state is AccountsLoadedState) {
          if (state.accounts.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('No accounts found. Please add an account.', style: TextStyle(color: Colors.grey)),
            );
          }

          final accounts = state.accounts;
          return Section(
            tiles: List.generate(accounts.length, (index) {
              final account = accounts.elementAt(index);
              return SectionTile(
                icon: PhysicalModel(color: Colors.white, shape: BoxShape.circle, child: Image.asset(account.avatarSrc)),
                title: Text(account.name, overflow: TextOverflow.ellipsis),
                secondaryIcon: account.id == widget.accountId ? const Icon(Icons.check_rounded) : null,
                onTap: () => widget.onPickup?.call(account),
              );
            }),
          );
        }

        return Skeletonizer(
          child: Section(
            tiles: List.generate(2, (_) => Skeleton.leaf(child: SectionTile(title: const Text('Loading names ...')))),
          ),
        );
      },
    );
  }
}
