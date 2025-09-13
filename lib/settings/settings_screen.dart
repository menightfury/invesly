// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

import 'package:cached_network_image/cached_network_image.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:path/path.dart';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/amcs/view/edit_amc/edit_amc_screen.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/login_page.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/extensions/color_extension.dart';
import 'package:invesly/common/presentations/widgets/color_picker.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';
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
                BlocSelector<AppCubit, AppState, InveslyUser?>(
                  selector: (state) => state.currentUser,
                  builder: (context, currentUser) {
                    final user = currentUser ?? InveslyUser.empty();
                    return Section(
                      title: Text(user.name.toSentenceCase()),
                      subTitle: Text(user.email),
                      icon: CircleAvatar(
                        backgroundImage: user.photoUrl != null ? CachedNetworkImageProvider(user.photoUrl!) : null,
                        child: user.photoUrl == null ? const Icon(Icons.person, size: 32.0) : null,
                      ),
                      trailingIcon: GestureDetector(
                        onTap: () => context.push(const EditAccountScreen()),
                        child: Text(
                          'Add',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      tiles: [
                        BlocBuilder<AccountsCubit, AccountsState>(
                          builder: (context, state) {
                            final isLoading = state.isLoading;
                            final isError = state.isError;
                            final accounts = state.isLoaded ? (state as AccountsLoadedState).accounts : null;

                            return BlocSelector<AppCubit, AppState, String?>(
                              selector: (state) => state.currentAccountId,
                              builder: (context, currentAccountId) {
                                return ColumnBuilder(
                                  spacing: 2.0,
                                  itemBuilder: (context, index) {
                                    final account = null;
                                    // final account = accounts?.elementAt(index);

                                    return BlocSelector<AppCubit, AppState, bool>(
                                      selector: (state) => state.currentAccountId == account?.id,
                                      builder: (context, isCurrentAccount) {
                                        $logger.i('rebuilding $account');
                                        return Shimmer(
                                          isLoading: !isLoading,

                                          child: SectionTile(
                                            onTap: () => context.read<AppCubit>().saveCurrentAccount(account.id),
                                            icon: CircleAvatar(backgroundImage: AssetImage(account.avatar)),
                                            title: account == null
                                                ? Skeleton(color: isError ? context.colors.error : null)
                                                : Text(account.name.toSentenceCase(), overflow: TextOverflow.ellipsis),
                                            description: account == null
                                                ? Skeleton(color: isError ? context.colors.error : null)
                                                : isCurrentAccount
                                                ? Text('Primary account')
                                                : null,
                                            trailingIcon: IconButton(
                                              onPressed: () => context.push(EditAccountScreen(initialAccount: account)),
                                              icon: const Icon(Icons.edit_note_rounded),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black.withAlpha(0x1F),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  itemCount: accounts?.length ?? 2, // dummy count for shimmer effect
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
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
                      title: Text('App language'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      icon: const Icon(Icons.language_rounded),
                      description: Text('English'),
                    ),
                    SectionTile(
                      title: Text('Currency'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      icon: const Icon(Icons.attach_money_rounded),
                      description: Text('Choose your preferred currency'),
                    ),
                    BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isPrivateMode,
                      builder: (context, isPrivateMode) {
                        return SectionTile.switchTile(
                          icon: const Icon(Icons.privacy_tip_outlined),
                          title: Text('Private mode'),
                          description: Text('Hide all monetary values'),
                          value: isPrivateMode,
                          onChanged: (value) => context.read<AppCubit>().setPrivateMode(value),
                        );
                      },
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.account_balance_outlined),
                      title: Text('Add AMC'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      description: Text('Add a new Asset Management Company to your list'),
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
                    BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isDynamicColor,
                      builder: (context, isDynamic) {
                        return SectionTile.switchTile(
                          title: Text('Dynamic color'),
                          // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                          icon: const Icon(Icons.format_color_fill_rounded),
                          description: Text('Choose the accent color to emphasize certain elements'),
                          value: isDynamic,
                          onChanged: (value) => context.read<AppCubit>().setDynamicColorMode(value),
                        );
                      },
                    ),
                    BlocSelector<AppCubit, AppState, (bool, int?)>(
                      selector: (state) => (state.isDynamicColor, state.accentColor),
                      builder: (context, state) {
                        final (isDynamic, accentColorInt) = state;
                        final accentColor = accentColorInt != null ? Color(accentColorInt) : context.colors.primary;
                        return SectionTile(
                          title: Text('Accent color'),
                          // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                          icon: const Icon(Icons.color_lens_rounded),
                          description: Text('Choose the accent color to emphasize certain elements'),
                          trailingIcon: CircleAvatar(
                            backgroundColor: isDynamic ? accentColor.withAlpha(120) : accentColor,
                          ),
                          onTap: () async {
                            final color = await InveslyColorPickerWidget.showModal(context, selectedColor: accentColor);
                            if (context.mounted && color != null) {
                              context.read<AppCubit>().setAccentColor(color.toARGB32());
                            }
                          },
                          enabled: !isDynamic,
                        );
                      },
                    ),
                    // SettingsTile
                    BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isDarkMode,
                      builder: (context, isDarkMode) {
                        return SectionTile.switchTile(
                          title: Text('Dark mode'),
                          icon: const Icon(Icons.format_paint),
                          value: isDarkMode,
                          onChanged: (value) => context.read<AppCubit>().setDarkTheme(value),
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
                      title: Text('Google Sign-in'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      description: Text('NA'), // TODO:
                      // onTap: () => context.push(const SignInDemo()),
                    ),
                    SectionTile(
                      icon: const Icon(Icons.restore_page_outlined),
                      title: Text('Restore'),
                      description: Text(
                        'Restore your data from a previously saved backup. This action will overwrite your current data.',
                      ),
                      onTap: () {},
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.restore_rounded),
                      title: Text('Manual import'),
                      description: Text('Import transaction from a .csv file.'),
                      onTap: () => context.push(const ImportTransactionsScreen()),
                    ),
                    SectionTile(
                      title: Text('Export transactions'),
                      icon: const Icon(Icons.backup_outlined),
                      description: Text('Export transactions locally to .csv file.'),
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
                      title: Text('Backup locally'),
                      icon: const Icon(Icons.import_export_rounded),
                      description: Text('This will create a new backup file locally.'),
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
                      title: Text('Backup to Google Drive'),
                      icon: const Icon(Icons.backup_outlined),
                      description: Text('Backup your data in a new backup file to Google Drive.'),
                      onTap: () => _onBackupToDrivePressed(context),
                    ),
                    SectionTile(
                      title: Text('Load drive files'),
                      icon: const Icon(Icons.backup_outlined),
                      description: Text('Load your data from a backup file in Google Drive.'),
                      onTap: () async {
                        gapis.AccessToken? accessToken = context.read<AppCubit>().state.gapiAccessToken;

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
                      title: Text('Privacy policy'),
                      description: Text('Read our privacy policy'),
                      onTap: () {},
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.gavel_rounded),
                      title: Text('Terms of use'),
                      description: Text('Read our terms of use'),
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
                      title: Text('Rate us'),
                      description: Text('Rate us on the Play Store'),
                      onTap: () {},
                    ),
                    SectionTile(
                      icon: const Icon(Icons.share_rounded),
                      title: Text('Share with friends'),
                      description: Text('Share Invesly with your friends and family'),
                      onTap: () {},
                    ),
                    SectionTile(
                      icon: const Icon(Icons.feedback_outlined),
                      title: Text('Feedback'),
                      description: Text('Report bugs, request features, or just say hi!'),
                      onTap: () {},
                    ),
                    SectionTile(
                      icon: const Icon(Icons.volunteer_activism_rounded),
                      title: Text('Donate'),
                      description: Text('Support the development of Invesly'),
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
    gapis.AccessToken? accessToken = context.read<AppCubit>().state.gapiAccessToken;

    try {
      if (accessToken == null) {
        final (_, accessToken_) = await LoginPage.startLoginFlow(context);

        // if (accessToken_ == null) return;
        accessToken = accessToken_;
      }
      final file = context.read<BackupRestoreRepository>().databaseFile;
      await context.read<AuthRepository>().saveFileInDrive(accessToken: accessToken, file: file);
      $logger.i('Backup created successfully');
    } catch (err) {
      $logger.e(err);
    }
  }
}
