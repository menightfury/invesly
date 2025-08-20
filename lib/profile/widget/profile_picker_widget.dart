import 'package:invesly/profile/cubit/profiles_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/profile/edit_profile/view/edit_profile_screen.dart';
import 'package:invesly/profile/model/profile_model.dart';

class InveslyProfilePickerWidget extends StatelessWidget {
  const InveslyProfilePickerWidget({super.key, this.accountId, this.onPickup});

  final String? accountId;
  final ValueChanged<InveslyProfile>? onPickup;

  static Future<InveslyProfile?> showModal(BuildContext context, [String? accountId]) async {
    return await showModalBottomSheet<InveslyProfile>(
      context: context,
      builder: (context) {
        return InveslyProfilePickerWidget(
          accountId: accountId,
          onPickup: (account) => Navigator.maybePop(context, account),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfilesCubit, ProfilesState>(
      builder: (context, state) {
        if (state is ProfilesErrorState) {
          return const PMErrorWidget();
        }

        if (state is ProfilesLoadedState) {
          final accounts = state.profiles;

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
                    context.push(const EditProfileScreen());
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
