import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/accounts/model/account_model.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class InveslyAccountPickerWidget extends StatelessWidget {
  const InveslyAccountPickerWidget({super.key, this.accountId, this.onPickup});

  final String? accountId;
  final ValueChanged<InveslyAccount>? onPickup;

  static Future<InveslyAccount?> showModal(BuildContext context, [String? accountId]) async {
    return await showModalBottomSheet<InveslyAccount>(
      context: context,
      // isScrollControlled: true,
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
        final isLoading = state.isLoading;
        final isError = state.isError;
        final accounts = state.isLoaded ? (state as AccountsLoadedState).accounts : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: <Widget>[
              ColumnBuilder(
                itemBuilder: (context, index) {
                  final account = accounts?.elementAt(index);

                  return Shimmer(
                    isLoading: isLoading,
                    child: ListTile(
                      leading: CircleAvatar(foregroundImage: account != null ? AssetImage(account.avatar) : null),
                      title: isLoading || isError
                          ? Skeleton(height: 24.0, color: isError ? context.colors.error : null)
                          : Text(account?.name ?? ''),
                      trailing: account?.id == accountId ? const Icon(Icons.check_rounded) : null,
                      onTap: account != null ? () => onPickup?.call(account) : null,
                    ),
                  );
                },
                itemCount: accounts?.length ?? 2, // dummy count for shimmer effect
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
      },
    );
  }
}
