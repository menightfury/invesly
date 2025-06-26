// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

// import 'package:googleapis/admin/directory_v1.dart';
import 'package:invesly/amcs/view/edit_amc/edit_amc_screen.dart';
import 'package:invesly/common/presentations/widgets/color_picker.dart';
import 'package:invesly/users/cubit/users_cubit.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/google_drive/google_drive.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/users/edit_user/view/edit_user_screen.dart';

import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

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
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(floating: true, snap: true, title: const Text('Profile & Settings')),
              SliverList(
                delegate: SliverChildListDelegate.fixed([
                  // ~~~ User Profile Section ~~~
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
                                users.isEmpty
                                    ? null
                                    : users.firstWhere((u) => u.id == userId, orElse: () => users.first);
                            final otherUsers = users.whereNot((u) => u.id == userId).toList();

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 16.0,
                                    children: <Widget>[
                                      if (currentUser != null)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            spacing: 8.0,
                                            children: <Widget>[
                                              CircleAvatar(backgroundImage: AssetImage(currentUser.avatar)),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(currentUser.name.toCapitalize()),
                                                  Text(
                                                    'PAN: ${currentUser.panNumber ?? "..."}',
                                                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                                                  ),
                                                  Text(
                                                    'AADHAAR: ${currentUser.aadhaarNumber ?? "..."}',
                                                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              IconButton(
                                                onPressed: () => context.push(EditUserScreen(initialUser: currentUser)),
                                                icon: Icon(Icons.edit_note_rounded),
                                              ),
                                            ],
                                          ),
                                        ),

                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text('More profiles (${otherUsers.length})'),
                                              GestureDetector(
                                                onTap: () => context.push(const EditUserScreen()),
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
                                          if (otherUsers.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: SizedBox(
                                                height: 56.0,
                                                child: ListView.separated(
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (context, index) {
                                                    final user = otherUsers[index];
                                                    return GestureDetector(
                                                      onTap:
                                                          () => context.read<SettingsCubit>().saveCurrentUser(user.id),
                                                      child: Column(
                                                        children: <Widget>[
                                                          CircleAvatar(backgroundImage: AssetImage(user.avatar)),
                                                          Text(
                                                            user.name.toCapitalize(),
                                                            style: textTheme.labelSmall?.copyWith(
                                                              color: Colors.grey[600],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  separatorBuilder: (_, _) => const SizedBox(width: 16.0),
                                                  itemCount: otherUsers.length,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return CircularProgressIndicator();
                    },
                  ),

                  // ~~~ Settings Section ~~~
                  SettingsSection(
                    title: 'General',
                    subTitle: 'Currency, language, etc.',
                    icon: const Icon(Icons.settings_outlined),
                    tiles: <Widget>[
                      SettingsTile(
                        title: 'App language',
                        // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                        icon: const Icon(Icons.language_rounded),
                        description: 'English',
                      ),
                      SettingsTile(
                        title: 'Currency',
                        // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                        icon: const Icon(Icons.attach_money_rounded),
                        description: 'Choose your preferred currency',
                      ),
                      SettingsTile.switchTile(
                        icon: const Icon(Icons.privacy_tip_outlined),
                        title: 'Private mode',
                        description: 'Hide all monetary values',
                        value: false,
                        onChanged: (value) {},
                      ),
                      SettingsTile.navigation(
                        icon: const Icon(Icons.account_balance_outlined),
                        title: 'Add AMC',
                        // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                        description: 'Add a new Asset Management Company to your list',
                        onTap: () => context.push(const EditAmcScreen()),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Appearance',
                    subTitle: 'App theme, colors',
                    icon: const Icon(Icons.palette_outlined),
                    tiles: <Widget>[
                      BlocSelector<SettingsCubit, SettingsState, bool>(
                        selector: (state) => state.isDynamicColor,
                        builder: (context, isDynamic) {
                          return SettingsTile.switchTile(
                            title: 'Dynamic color',
                            // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                            icon: const Icon(Icons.format_color_fill_rounded),
                            description: 'Choose the accent color to emphasize certain elements',
                            value: isDynamic,
                            onChanged: (value) => context.read<SettingsCubit>().setDynamicColorMode(value),
                          );
                        },
                      ),
                      BlocSelector<SettingsCubit, SettingsState, (bool, int?)>(
                        selector: (state) => (state.isDynamicColor, state.accentColor),
                        builder: (context, state) {
                          final (isDynamic, accentColorInt) = state;
                          final accentColor = accentColorInt != null ? Color(accentColorInt) : context.color.primary;
                          return SettingsTile(
                            title: 'Accent color',
                            // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                            icon: const Icon(Icons.color_lens_rounded),
                            description: 'Choose the accent color to emphasize certain elements',
                            trailingIcon: CircleAvatar(
                              backgroundColor: isDynamic ? accentColor.withAlpha(120) : accentColor,
                            ),
                            onTap: () async {
                              final colorInt = await InveslyColorPickerWidget.showModal(context);
                              if (context.mounted && colorInt != null) {
                                context.read<SettingsCubit>().setAccentColor(colorInt);
                              }
                            },
                            enabled: !isDynamic,
                          );
                        },
                      ),
                      // SettingsTile
                      BlocSelector<SettingsCubit, SettingsState, bool>(
                        selector: (state) => state.isDarkMode,
                        builder: (context, isDarkMode) {
                          return SettingsTile.switchTile(
                            title: 'Dark mode',
                            icon: const Icon(Icons.format_paint),
                            value: isDarkMode,
                            onChanged: (value) => context.read<SettingsCubit>().setDarkTheme(value),
                          );
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Backup & Restore',
                    subTitle: 'Last backup: 2023-10-01',
                    icon: const Icon(Icons.import_export_rounded),
                    tiles: [
                      SettingsTile(
                        icon: const Icon(Icons.login),
                        title: 'Google Sign-in',
                        description: 'me.nightfury@gmail.com',
                        // value: Text(context.watch<SettingsRepository>().currentLocale.name),
                        onTap: () => context.push(const SignInDemo()),
                      ),
                      SettingsTile(
                        icon: const Icon(Icons.restore_page_outlined),
                        title: 'Restore',
                        description:
                            'Restore your data from a previously saved backup. This action will overwrite your current data.',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: const Icon(Icons.restore_rounded),
                        title: 'Manual import',
                        description: 'Import transaction from a .csv file.',
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: 'Export',
                        icon: const Icon(Icons.backup_outlined),
                        description: 'Export your data locally to .csv file.',
                        onTap: () {},
                      ),
                      SettingsTile(
                        title: 'Backup',
                        icon: const Icon(Icons.backup_outlined),
                        description: 'Backup your data to Google Drive. This will create a new backup file.',
                        onTap: () {},
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Terms & Privacy',
                    subTitle: 'Privacy policy, terms of service, etc.',
                    icon: const Icon(Icons.gavel_rounded),
                    tiles: [
                      SettingsTile.navigation(
                        icon: const Icon(Icons.policy_outlined),
                        title: 'Privacy policy',
                        description: 'Read our privacy policy',
                        onTap: () {},
                      ),
                      SettingsTile.navigation(
                        icon: const Icon(Icons.generating_tokens_outlined),
                        title: 'Terms of use',
                        description: 'Read our terms of use',
                        onTap: () {},
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: 'Help us',
                    subTitle: 'Thank you for your contribution to Invesly',
                    tiles: [
                      SettingsTile.navigation(
                        icon: const Icon(Icons.star_rate_rounded),
                        title: 'Rate us',
                        description: 'Rate us on the Play Store',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: const Icon(Icons.share_rounded),
                        title: 'Share with friends',
                        description: 'Share Invesly with your friends and family',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: const Icon(Icons.feedback_outlined),
                        title: 'Feedback',
                        description: 'Report bugs, request features, or just say hi!',
                        onTap: () {},
                      ),
                      SettingsTile(
                        icon: const Icon(Icons.volunteer_activism_rounded),
                        title: 'Donate',
                        description: 'Support the development of Invesly',
                        onTap: () {},
                      ),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
