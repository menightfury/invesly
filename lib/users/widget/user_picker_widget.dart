import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/common_libs.dart';

class InveslyUserPickerWidget extends StatelessWidget {
  const InveslyUserPickerWidget({super.key, this.userId, this.onPickup});

  final String? userId;
  final ValueChanged<String>? onPickup;

  static Future<String?> showModal(BuildContext context, [String? userId]) async {
    return await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return InveslyUserPickerWidget(userId: userId, onPickup: (userId) => Navigator.maybePop(context, userId));
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
                      onTap: () => onPickup?.call(user.id),
                    );
                  },
                  itemCount: users.length,
                ),
                ListTile(
                  leading: const Icon(Icons.add_reaction_rounded),
                  title: const Text('Add new user'),
                  onTap: () {
                    // Navigator.maybePop(context);
                    context.push(AppRouter.editUser);
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
