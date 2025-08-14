import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/users/edit_user/view/edit_user_screen.dart';
import 'package:invesly/users/model/user_model.dart';

class InveslyUserPickerWidget extends StatelessWidget {
  const InveslyUserPickerWidget({super.key, this.userId, this.onPickup});

  final String? userId;
  final ValueChanged<InveslyUser>? onPickup;

  static Future<InveslyUser?> showModal(BuildContext context, [String? userId]) async {
    return await showModalBottomSheet<InveslyUser>(
      context: context,
      builder: (context) {
        return InveslyUserPickerWidget(userId: userId, onPickup: (user) => Navigator.maybePop(context, user));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state is UsersErrorState) {
          return const PMErrorWidget();
        }

        if (state is UsersLoadedState) {
          final users = state.users;

          if (users.isEmpty) {
            return const EmptyWidget(label: 'No users exists');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: <Widget>[
                ColumnBuilder(
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return ListTile(
                      leading: CircleAvatar(foregroundImage: AssetImage(user.avatar)),
                      title: Text(user.name),
                      trailing: user.id == userId ? const Icon(Icons.check_rounded) : null,
                      onTap: () => onPickup?.call(user),
                    );
                  },
                  itemCount: users.length,
                ),
                ListTile(
                  leading: const Icon(Icons.add_reaction_rounded),
                  title: const Text('Add new user'),
                  onTap: () {
                    // Navigator.maybePop(context);
                    // context.push(AppRouter.editUser);
                    context.push(const EditUserScreen());
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
