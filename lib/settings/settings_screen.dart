// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

// import 'package:googleapis/admin/directory_v1.dart';
import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/google_drive/google_drive.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocListener<UsersCubit, UsersState>(
      listener: (context, state) {
        // if (state is! UsersLoadedState) {
        //   context.go(AppRouter.splash);
        // } else {
        //   if (state.hasNoUser) {
        //     context.go(AppRouter.editUser);
        //   }
        // }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Profile screen')),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersErrorState) {
                      return Text('Failed to load users');
                    }

                    if (state is UsersLoadedState) {
                      final users = state.users;
                      return BlocSelector<SettingsCubit, SettingsState, String?>(
                        selector: (state) => state.currentUserId,
                        builder: (context, userId) {
                          final currentUser =
                              users.isEmpty ? null : users.firstWhere((u) => u.id == userId, orElse: () => users.first);
                          final otherUsers = users.whereNot((u) => u.id == userId).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16.0,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Material(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    child: Row(
                                      spacing: 8.0,
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundImage: currentUser != null ? AssetImage(currentUser.avatar) : null,
                                          child: currentUser == null ? Icon(Icons.person_pin) : null,
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(currentUser?.name.toCapitalize() ?? ''),
                                            Text(
                                              'PAN: ${currentUser?.panNumber ?? "..."}',
                                              style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                                            ),
                                            Text(
                                              'AADHAAR: ${currentUser?.aadhaarNumber ?? "..."}',
                                              style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        IconButton(
                                          onPressed: () => context.push(AppRouter.editUser, extra: currentUser),
                                          icon: Icon(Icons.edit_note_rounded),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if (otherUsers.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('More profiles (${otherUsers.length})'),
                                          GestureDetector(
                                            onTap: () => context.push(AppRouter.editUser),
                                            child: Text(
                                              'Add',
                                              style: textTheme.labelMedium?.copyWith(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 60.0,
                                      child: ListView.separated(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          final user = otherUsers[index];
                                          return GestureDetector(
                                            onTap: () => context.read<SettingsCubit>().saveCurrentUser(user.id),
                                            child: Column(
                                              children: <Widget>[
                                                CircleAvatar(backgroundImage: AssetImage(user.avatar)),
                                                Text(
                                                  user.name.toCapitalize(),
                                                  style: textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (_, _) => const SizedBox(width: 16.0),
                                        itemCount: otherUsers.length,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        },
                      );
                    }

                    return CircularProgressIndicator();
                  },
                ),
                _SettingsSection(
                  title: const Text('General'),
                  tiles: <Widget>[
                    _SettingsTile(
                      icon: const Icon(Icons.language),
                      title: const Text('Test page'),

                      // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                      onTap: () => context.push(AppRouter.test),
                    ),
                    _SettingsTile(
                      icon: const Icon(Icons.language),
                      title: const Text('Add AMC'),

                      // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                      onTap: () => context.push(AppRouter.editAmc),
                    ),
                    _SettingsTile(
                      icon: const Icon(Icons.language),
                      title: const Text('Google Sign-in'),

                      // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                      onTap:
                          () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignInDemo())),
                    ),
                    _SettingsTile(
                      icon: const Icon(Icons.language),
                      title: const Text('Language'),

                      // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                      // onTap: () => _showLanguageSelectionModal(context),
                    ),
                    // SettingsTile
                    BlocSelector<SettingsCubit, SettingsState, bool>(
                      selector: (state) => state.isDarkMode,
                      builder: (context, value) {
                        return _SettingsTile.switchTile(
                          onChanged: (value) => context.read<SettingsCubit>().setDarkTheme(value),
                          value: value,
                          icon: const Icon(Icons.format_paint),
                          title: const Text('Dark mode'),
                        );
                      },
                    ),
                    _SettingsTile(icon: const Icon(Icons.format_paint), title: const Text('Currency')),
                    _SettingsTile.navigation(
                      icon: const Icon(Icons.format_paint),
                      title: const Text('Security'),
                      // onTap: () => context.push(Screens.security),
                    ),
                    _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Notification')),
                    _SettingsTile.navigation(
                      icon: const Icon(Icons.format_paint),
                      title: const Text('Backup / Restore'),
                      // onTap: () => context.push(AppRouter.backup),
                    ),
                  ],
                ),
                _SettingsSection(
                  title: const Text('More'),
                  tiles: [
                    _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Privacy policy')),
                    _SettingsTile.navigation(icon: const Icon(Icons.format_paint), title: const Text('Terms')),
                    _SettingsTile.navigation(
                      icon: const Icon(Icons.format_paint),
                      title: const Text('Help & feedback'),
                    ),
                  ],
                ),

                // ~ Extra space for content below bottom navigation bar
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // void _showLanguageSelectionModal(BuildContext context) {
  //   // final Map<String, String> languages = {'bn': 'Bengali', 'en': 'English'};
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return LocalePicker(
  //         onChanged: (language) {
  //           context.read<SettingsRepository>().saveLocale(language);
  //           Navigator.pop(context);
  //         },
  //       );
  //     },
  //   );
  // }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({super.key, this.title, required this.tiles});

  final Widget? title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    if (title == null) {
      return buildTileList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsetsDirectional.only(top: 24, bottom: 10, start: 24, end: 24), child: title),
        buildTileList(),
      ],
    );
  }

  Widget buildTileList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          // color: theme.disabledColor, // TODO: fix background color
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: tiles),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  _SettingsTile({this.title, this.subTitle, this.icon, Widget? value, VoidCallback? onTap, bool enabled = true})
    : content = ListTile(
        title: title,
        subtitle: subTitle,
        leading: icon,
        trailing: value,
        onTap: onTap,
        enabled: enabled,
      );

  _SettingsTile.switchTile({
    this.title,
    this.subTitle,
    this.icon,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) : content = SwitchListTile(title: title, subtitle: subTitle, secondary: icon, value: value, onChanged: onChanged);

  _SettingsTile.navigation({this.title, this.subTitle, this.icon, VoidCallback? onTap, bool enabled = true})
    : content = ListTile(
        title: title,
        subtitle: subTitle,
        leading: icon,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        enabled: enabled,
      );

  final Widget? title;
  final Widget? subTitle;
  final Widget? icon;

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return content;
  }
}
