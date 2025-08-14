import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/accounts/model/account_model.dart';

class InveslyAccountPickerWidget extends StatelessWidget {
  const InveslyAccountPickerWidget({super.key, this.accountId, this.onPickup});

  final String? accountId;
  final ValueChanged<InveslyAccount>? onPickup;

  static Future<InveslyAccount?> showModal(BuildContext context, [String? accountId]) async {
    return await showModalBottomSheet<InveslyAccount>(
      context: context,
      builder: (context) {
        return InveslyAccountPickerWidget(
          accountId: accountId,
          onPickup: (account) => Navigator.maybePop(context, account),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (context, state) {
        if (state is AccountsErrorState) {
          return const PMErrorWidget();
        }

        if (state is AccountsLoadedState) {
          final accounts = state.accounts;

          if (accounts.isEmpty) {
            return const EmptyWidget(label: 'No accounts exists');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: <Widget>[
                ColumnBuilder(
                  itemBuilder: (context, index) {
                    final account = accounts[index];

                    return ListTile(
                      leading: CircleAvatar(foregroundImage: AssetImage(account.avatar)),
                      title: Text(account.name),
                      trailing: account.id == accountId ? const Icon(Icons.check_rounded) : null,
                      onTap: () => onPickup?.call(account),
                    );
                  },
                  itemCount: accounts.length,
                ),
                ListTile(
                  leading: const Icon(Icons.add_reaction_rounded),
                  title: const Text('Add new account'),
                  onTap: () {
                    // Navigator.maybePop(context);
                    // context.push(AppRouter.editAccount);
                    context.push(const EditAccountScreen());
                  },
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
