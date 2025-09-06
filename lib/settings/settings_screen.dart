// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/login_page.dart';
import 'package:path/path.dart';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/amcs/view/edit_amc/edit_amc_screen.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/color_picker.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/settings/import_transactions/import_transactions_screen.dart';
import 'package:invesly/transactions/model/transaction_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // _askForPermission();
  }

  // Future<void> _askForPermission() async {
  //   // ask for permission to access external storage
  //   // Not required for Android 13 (Api 33) and above
  //   if (!kIsWeb) {
  //     final status = await Permission.storage.request();
  //     if (status.isDenied || status.isPermanentlyDenied) {
  //       // If the user denies the permission, you can show a dialog or a snackbar
  //       // to inform them that the app needs this permission to function properly.
  //       $logger.w('Storage permission denied. App may not work as expected.');
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('Storage permission is required for backup and restore functionality.'),
  //             backgroundColor: Colors.deepOrangeAccent,
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(floating: true, snap: true, title: const Text('Profile & Settings')),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                // ~~~ User Profile Section ~~~
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    spacing: 2.0,
                    children: <Widget>[
                      BlocSelector<SettingsCubit, SettingsState, InveslyUser?>(
                        selector: (state) => state.currentUser,
                        builder: (context, currentUser) {
                          final user = currentUser ?? InveslyUser.empty();
                          return Section(
                            title: Text(user.name.toSentenceCase()),
                            subTitle: Text(user.email),
                            icon: CircleAvatar(
                              backgroundImage: user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null ? const Icon(Icons.person, size: 32.0) : null,
                            ),
                            tiles: [
                              BlocBuilder<AccountsCubit, AccountsState>(
                                builder: (context, state) {
                                  if (state is AccountsErrorState) {
                                    return Text('Failed to load accounts');
                                  }

                                  if (state is AccountsLoadedState) {
                                    final accounts = state.accounts;

                                    return BlocSelector<SettingsCubit, SettingsState, String?>(
                                      selector: (state) => state.currentAccountId,
                                      builder: (context, currentAccountId) {
                                        return ColumnBuilder(
                                          spacing: 2.0,
                                          itemBuilder: (context, index) {
                                            final account = accounts[index];
                                            final isCurrentAccount = account.id == currentAccountId;
                                            late final BorderRadius borderRadius;
                                            if (index == accounts.length - 1) {
                                              borderRadius = BorderRadius.vertical(
                                                top: const Radius.circular(4.0),
                                                bottom: AppConstants.cardBorderRadius.bottomLeft,
                                              );
                                            } else {
                                              borderRadius = const BorderRadius.all(Radius.circular(4.0));
                                            }
                                            return ListTile(
                                              // contentPadding: EdgeInsets.zero,
                                              onTap: () => context.read<SettingsCubit>().saveCurrentAccount(account.id),
                                              tileColor: context.colors.primaryContainer,
                                              leading: CircleAvatar(backgroundImage: AssetImage(account.avatar)),
                                              shape: RoundedRectangleBorder(borderRadius: borderRadius),
                                              title: Text(
                                                account.name.toSentenceCase(),
                                                style: context.textTheme.bodyMedium?.copyWith(
                                                  fontWeight: isCurrentAccount ? FontWeight.w600 : null,
                                                ),
                                              ),
                                              subtitle: isCurrentAccount
                                                  ? Text(
                                                      'Primary Account',
                                                      style: context.textTheme.labelMedium?.copyWith(
                                                        color: context.colors.secondary,
                                                      ),
                                                    )
                                                  : null,
                                              trailing: IconButton(
                                                onPressed: () =>
                                                    context.push(EditAccountScreen(initialAccount: account)),
                                                icon: Icon(Icons.edit_note_rounded),
                                                style: IconButton.styleFrom(
                                                  // foregroundColor: context.colors.onPrimary,
                                                  backgroundColor: Colors.black.withAlpha(0x1F),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: accounts.length,
                                        );
                                      },
                                    );
                                  }

                                  return CircularProgressIndicator();
                                },
                              ),
                            ],
                          );
                          return ListTile(
                            title: Text(
                              user.name.toSentenceCase(),
                              style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: user.photoUrl != null
                                  ? CachedNetworkImageProvider(user.photoUrl!)
                                  : null,
                              child: user.photoUrl == null ? const Icon(Icons.person, size: 32.0) : null,
                            ),
                            trailing: GestureDetector(
                              onTap: () => context.push(const EditAccountScreen()),
                              child: Text(
                                'Add',
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              user.email,
                              style: context.textTheme.labelMedium?.copyWith(color: context.colors.secondary),
                            ),
                            tileColor: context.colors.primaryContainer.darken(10),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0),
                                bottom: Radius.circular(4.0),
                              ),
                            ),
                          );
                        },
                      ),

                      // InveslyDivider(),
                      BlocBuilder<AccountsCubit, AccountsState>(
                        builder: (context, state) {
                          if (state is AccountsErrorState) {
                            return Text('Failed to load accounts');
                          }

                          if (state is AccountsLoadedState) {
                            final accounts = state.accounts;

                            return BlocSelector<SettingsCubit, SettingsState, String?>(
                              selector: (state) => state.currentAccountId,
                              builder: (context, currentAccountId) {
                                return ColumnBuilder(
                                  spacing: 2.0,
                                  itemBuilder: (context, index) {
                                    final account = accounts[index];
                                    final isCurrentAccount = account.id == currentAccountId;
                                    late final BorderRadius borderRadius;
                                    if (index == accounts.length - 1) {
                                      borderRadius = BorderRadius.vertical(
                                        top: const Radius.circular(4.0),
                                        bottom: AppConstants.cardBorderRadius.bottomLeft,
                                      );
                                    } else {
                                      borderRadius = const BorderRadius.all(Radius.circular(4.0));
                                    }
                                    return ListTile(
                                      // contentPadding: EdgeInsets.zero,
                                      onTap: () => context.read<SettingsCubit>().saveCurrentAccount(account.id),
                                      tileColor: context.colors.primaryContainer,
                                      leading: CircleAvatar(backgroundImage: AssetImage(account.avatar)),
                                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                                      title: Text(
                                        account.name.toSentenceCase(),
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          fontWeight: isCurrentAccount ? FontWeight.w600 : null,
                                        ),
                                      ),
                                      subtitle: isCurrentAccount
                                          ? Text(
                                              'Primary Account',
                                              style: context.textTheme.labelMedium?.copyWith(
                                                color: context.colors.secondary,
                                              ),
                                            )
                                          : null,
                                      trailing: IconButton(
                                        onPressed: () => context.push(EditAccountScreen(initialAccount: account)),
                                        icon: Icon(Icons.edit_note_rounded),
                                        style: IconButton.styleFrom(
                                          // foregroundColor: context.colors.onPrimary,
                                          backgroundColor: Colors.black.withAlpha(0x1F),
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: accounts.length,
                                );
                              },
                            );
                          }

                          return CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                ),

                const Gap(16.0),

                // ~~~ Settings Section ~~~
                Section(
                  title: Text('General'),
                  subTitle: Text('Currency, language, etc.'),
                  // icon: const Icon(Icons.settings_outlined),
                  // content: SectionTiles(),
                  tiles: <Widget>[
                    SectionTile(
                      title: 'App language',
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      icon: const Icon(Icons.language_rounded),
                      description: 'English',
                    ),
                    SectionTile(
                      title: 'Currency',
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      icon: const Icon(Icons.attach_money_rounded),
                      description: 'Choose your preferred currency',
                    ),
                    BlocSelector<SettingsCubit, SettingsState, bool>(
                      selector: (state) => state.isPrivateMode,
                      builder: (context, isPrivateMode) {
                        return SectionTile.switchTile(
                          icon: const Icon(Icons.privacy_tip_outlined),
                          title: 'Private mode',
                          description: 'Hide all monetary values',
                          value: isPrivateMode,
                          onChanged: (value) => context.read<SettingsCubit>().setPrivateMode(value),
                        );
                      },
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.account_balance_outlined),
                      title: 'Add AMC',
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      description: 'Add a new Asset Management Company to your list',
                      onTap: () => context.push(const EditAmcScreen()),
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: Text('Appearance'),
                  subTitle: Text('App theme, colors'),
                  // icon: const Icon(Icons.palette_outlined),
                  tiles: <Widget>[
                    BlocSelector<SettingsCubit, SettingsState, bool>(
                      selector: (state) => state.isDynamicColor,
                      builder: (context, isDynamic) {
                        return SectionTile.switchTile(
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
                        final accentColor = accentColorInt != null ? Color(accentColorInt) : context.colors.primary;
                        return SectionTile(
                          title: 'Accent color',
                          // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                          icon: const Icon(Icons.color_lens_rounded),
                          description: 'Choose the accent color to emphasize certain elements',
                          trailingIcon: CircleAvatar(
                            backgroundColor: isDynamic ? accentColor.withAlpha(120) : accentColor,
                          ),
                          onTap: () async {
                            final color = await InveslyColorPickerWidget.showModal(context, selectedColor: accentColor);
                            if (context.mounted && color != null) {
                              context.read<SettingsCubit>().setAccentColor(color.toARGB32());
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
                        return SectionTile.switchTile(
                          title: 'Dark mode',
                          icon: const Icon(Icons.format_paint),
                          value: isDarkMode,
                          onChanged: (value) => context.read<SettingsCubit>().setDarkTheme(value),
                        );
                      },
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: Text('Backup & Restore'),
                  subTitle: Text('Last backup: 2023-10-01'),
                  // icon: const Icon(Icons.import_export_rounded),
                  tiles: [
                    SectionTile(
                      icon: const Icon(Icons.login),
                      title: 'Google Sign-in',
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      description: 'NA', // TODO:
                      // onTap: () => context.push(const SignInDemo()),
                    ),
                    SectionTile(
                      icon: const Icon(Icons.restore_page_outlined),
                      title: 'Restore',
                      description:
                          'Restore your data from a previously saved backup. This action will overwrite your current data.',
                      onTap: () {},
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.restore_rounded),
                      title: 'Manual import',
                      description: 'Import transaction from a .csv file.',
                      onTap: () => context.push(const ImportTransactionsScreen()),
                    ),
                    SectionTile(
                      title: 'Export transactions',
                      icon: const Icon(Icons.backup_outlined),
                      description: 'Export transactions locally to .csv file.',
                      onTap: () async {
                        late final SnackBar snackBar;
                        try {
                          final csvData = await context.read<TransactionRepository>().transactionsToCsv();
                          final file = await BackupRestoreRepository.exportCsv(csvData);
                          if (file != null) {
                            final fileName = basename(file.path);
                            snackBar = SnackBar(
                              content: Text('$fileName saved successfully to ${file.parent.path}'),
                              backgroundColor: Colors.teal,
                            );
                          } else {
                            snackBar = SnackBar(
                              content: Text('Error in saving file'),
                              backgroundColor: Colors.deepOrange,
                            );
                          }
                        } catch (err) {
                          $logger.e(err);
                          snackBar = SnackBar(
                            content: Text('Error in saving file'),
                            backgroundColor: Colors.deepOrange,
                          );
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    SectionTile(
                      title: 'Backup locally',
                      icon: const Icon(Icons.import_export_rounded),
                      description: 'This will create a new backup file locally.',
                      onTap: () async {
                        late final SnackBar snackBar;
                        try {
                          // String? path = await FilePicker.platform.getDirectoryPath();
                          // if (path == null || path.isEmpty || !context.mounted) {
                          //   return;
                          // }

                          final file = await context.read<BackupRestoreRepository>().exportDatabaseFile();
                          if (file != null) {
                            snackBar = SnackBar(
                              content: Text('File saved successfully, ${file.path}'),
                              backgroundColor: Colors.teal,
                            );
                          } else {
                            snackBar = SnackBar(
                              content: Text('Error in saving file'),
                              backgroundColor: Colors.deepOrange,
                            );
                          }
                        } catch (err) {
                          $logger.e(err);
                          snackBar = SnackBar(
                            content: Text('Error in saving file'),
                            backgroundColor: Colors.deepOrange,
                          );
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                    ),
                    SectionTile(
                      title: 'Drive backup',
                      icon: const Icon(Icons.backup_outlined),
                      description: 'Backup your data in a new backup file to Google Drive.',
                      onTap: () => _onBackupToDrivePressed(context),
                    ),
                    SectionTile(
                      title: 'Load drive files',
                      icon: const Icon(Icons.backup_outlined),
                      description: 'Load your data from a backup file in Google Drive.',
                      onTap: () async {
                        AccessToken? accessToken = context.read<SettingsCubit>().state.gapiAccessToken;

                        if (accessToken == null) {
                          final user = await context.read<AuthRepository>().signInWithGoogle();
                          if (user == null) {
                            $logger.w('Google sign-in failed');
                            return;
                          }

                          accessToken = await context.read<AuthRepository>().getAccessToken(user);
                        }
                        final files = await context.read<AuthRepository>().getDriveFiles(accessToken);
                        $logger.i(files);
                      },
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: Text('Terms & Privacy'),
                  subTitle: Text('Privacy policy, terms of service, etc.'),
                  // icon: const Icon(Icons.gavel_rounded),
                  tiles: [
                    SectionTile.navigation(
                      icon: const Icon(Icons.policy_outlined),
                      title: 'Privacy policy',
                      description: 'Read our privacy policy',
                      onTap: () {},
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.gavel_rounded),
                      title: 'Terms of use',
                      description: 'Read our terms of use',
                      onTap: () {},
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: Text('Help us'),
                  subTitle: Text('Thank you for your contribution to Invesly'),
                  tiles: [
                    SectionTile.navigation(
                      icon: const Icon(Icons.star_rate_rounded),
                      title: 'Rate us',
                      description: 'Rate us on the Play Store',
                      onTap: () {},
                    ),
                    SectionTile(
                      icon: const Icon(Icons.share_rounded),
                      title: 'Share with friends',
                      description: 'Share Invesly with your friends and family',
                      onTap: () {},
                    ),
                    SectionTile(
                      icon: const Icon(Icons.feedback_outlined),
                      title: 'Feedback',
                      description: 'Report bugs, request features, or just say hi!',
                      onTap: () {},
                    ),
                    SectionTile(
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
    );
  }

  Future<void> _onBackupToDrivePressed(BuildContext context) async {
    AccessToken? accessToken = context.read<SettingsCubit>().state.gapiAccessToken;
    try {
      if (accessToken == null) {
        final (_, accessToken_) = await LoginPage.startLoginFlow(context);

        if (accessToken_ == null) return;

        final file = context.read<BackupRestoreRepository>().dbFile;
        await context.read<AuthRepository>().saveFileInDrive(accessToken: accessToken_, file: file);
        $logger.i('Backup created successfully');
      }
    } catch (err) {
      $logger.e(err);
    }
  }
}
