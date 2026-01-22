// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/database/import_backup_page.dart';
import 'package:invesly/intro/splash_page.dart';
import 'package:path/path.dart';

import 'package:invesly/accounts/cubit/accounts_cubit.dart';
import 'package:invesly/accounts/edit_account/view/edit_account_screen.dart';
import 'package:invesly/amcs/view/all_amcs_screen.dart';
import 'package:invesly/amcs/view/edit_amc/edit_amc_screen.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/auth_ui_functions.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/model/currency.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/animations/shimmer.dart';
import 'package:invesly/common/presentations/widgets/circle_avatar.dart';
import 'package:invesly/common/presentations/widgets/color_picker.dart';
import 'package:invesly/common/presentations/widgets/date_format_picker.dart';
import 'package:invesly/common/presentations/widgets/section.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_repository.dart';
import 'package:invesly/settings/import_transactions/import_transactions_screen.dart';
import 'package:invesly/settings/currency_selector_screen.dart';
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
                BlocBuilder<AccountsCubit, AccountsState>(
                  builder: (context, accountsState) {
                    final isLoading = accountsState.isLoading;
                    final isError = accountsState.isError;
                    final accounts = accountsState.isLoaded ? (accountsState as AccountsLoadedState).accounts : null;

                    return BlocSelector<AppCubit, AppState, InveslyUser?>(
                      selector: (state) => state.user,
                      builder: (context, currentUser) {
                        // final user = currentUser ?? InveslyUser.empty();
                        return Section(
                          title: Text(currentUser.isNotNullOrEmpty ? currentUser!.name.toSentenceCase() : 'Investor'),
                          subTitle: currentUser.isNotNullOrEmpty ? Text(currentUser?.email ?? 'e-mail: NA') : null,
                          icon: currentUser.isNotNullOrEmpty
                              ? InveslyUserCircleAvatar(user: currentUser!)
                              : CircleAvatar(child: const Icon(Icons.person_rounded)),
                          trailingIcon: MenuAnchor(
                            menuChildren: [
                              BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.user.isNotNullOrEmpty,
                                builder: (_, userExists) {
                                  if (userExists) {
                                    return const SizedBox.shrink();
                                  }
                                  return MenuItemButton(
                                    leadingIcon: Icon(Icons.login_rounded, color: context.theme.primaryColor),
                                    onPressed: () => startLoginFlow(context),
                                    child: const Text('Sign in'),
                                  );
                                },
                              ),
                              MenuItemButton(
                                leadingIcon: Icon(Icons.add_rounded, color: context.theme.primaryColor),
                                onPressed: () => context.push(const EditAccountScreen()),
                                child: const Text('Add new account'),
                              ),
                              BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.user.isNullOrEmpty,
                                builder: (_, userNotExists) {
                                  if (userNotExists) {
                                    return const SizedBox.shrink();
                                  }
                                  return MenuItemButton(
                                    leadingIcon: Icon(Icons.logout_rounded, color: context.colors.error),
                                    onPressed: () => startLogoutFlow(context),
                                    // style: MenuItemButton.styleFrom(
                                    //   backgroundColor: context.colors.error.withAlpha(0x1F),
                                    // ),
                                    child: Text('Sign out', style: TextStyle(color: context.colors.error)),
                                  );
                                },
                              ),
                            ],
                            // alignmentOffset: Offset(-130, 0),
                            style: MenuStyle(
                              alignment: Alignment(-6.0, -1.0),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: iCardBorderRadius)),
                            ),
                            builder: (context, controller, child) {
                              return IconButton(
                                onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                                icon: child!,
                              );
                            },
                            child: const Icon(Icons.more_vert),
                          ),

                          tiles: List.generate(
                            accounts?.length ?? (isLoading ? 2 : 0), // dummy count for shimmer effect
                            (index) {
                              final account = accounts?.elementAt(index);
                              return BlocSelector<AppCubit, AppState, bool>(
                                selector: (state) => state.primaryAccountId == account?.id,
                                builder: (context, isCurrentAccount) {
                                  return Shimmer(
                                    isLoading: isLoading,
                                    child: SectionTile(
                                      // onTap: () => context.read<AppCubit>().saveCurrentAccount(account.id),
                                      icon: CircleAvatar(
                                        backgroundColor: isError ? context.colors.error : context.theme.canvasColor,
                                        backgroundImage: account != null ? AssetImage(account.avatarSrc) : null,
                                      ),
                                      title: account == null
                                          ? Skeleton2(color: isError ? context.colors.error : null)
                                          : Text(account.name.toSentenceCase(), overflow: TextOverflow.ellipsis),
                                      subtitle: account == null
                                          ? Skeleton2(color: isError ? context.colors.error : null)
                                          : isCurrentAccount
                                          ? const Text('Primary account')
                                          : null,
                                      trailingIcon: IconButton(
                                        onPressed: () => context.push(EditAccountScreen(initialAccount: account)),
                                        icon: const Icon(Icons.edit_note_rounded),
                                        style: IconButton.styleFrom(backgroundColor: Colors.black.withAlpha(0x1F)),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                const Gap(16.0),

                // ~~~ Settings Section ~~~
                Section(
                  title: const Text('General'),
                  subTitle: const Text('Currency, language, etc.'),
                  // icon: const Icon(Icons.settings_outlined),
                  // content: SectionTiles(),
                  tiles: <Widget>[
                    SectionTile(
                      title: const Text('App language'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      icon: const Icon(Icons.language_rounded),
                      subtitle: const Text('English'),
                    ),
                    SectionTile(
                      title: const Text('Date format'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      icon: const Icon(Icons.language_rounded),
                      subtitle: const Text('English'),
                      onTap: () async {
                        final value = await InveslyDateFormatPicker.showModal(context);
                        $logger.d(value);
                      },
                    ),
                    BlocSelector<AppCubit, AppState, Currency?>(
                      selector: (state) => state.currency,
                      builder: (context, currency) {
                        return SectionTile(
                          title: const Text('Currency'),
                          // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                          icon: const Icon(Icons.attach_money_rounded),
                          subtitle: Text(
                            currency != null
                                ? '${currency.name} (${currency.symbol})'
                                : 'Choose your preferred currency',
                          ),
                          onTap: () => context.push(const CurrencySelectorScreen()),
                        );
                      },
                    ),
                    BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isPrivateMode,
                      builder: (context, isPrivateMode) {
                        return SectionTile.switchTile(
                          icon: const Icon(Icons.privacy_tip_outlined),
                          title: const Text('Private mode'),
                          subtitle: const Text('Hide all monetary values'),
                          value: isPrivateMode,
                          onChanged: (value) => context.read<AppCubit>().updatePrivateMode(value),
                        );
                      },
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.account_balance_outlined),
                      title: const Text('View all AMCs'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      subtitle: const Text('View and manage your Asset Management Companies'),
                      onTap: () => context.push(const AllAmcsScreen()),
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.account_balance_outlined),
                      title: const Text('Add AMC'),
                      // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                      subtitle: const Text('Add a new Asset Management Company to your list'),
                      onTap: () => context.push(const EditAmcScreen()),
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: const Text('Appearance'),
                  subTitle: const Text('App theme, colors'),
                  // icon: const Icon(Icons.palette_outlined),
                  tiles: <Widget>[
                    BlocSelector<AppCubit, AppState, bool>(
                      selector: (state) => state.isDynamicColor,
                      builder: (context, isDynamic) {
                        return SectionTile.switchTile(
                          title: Text('Dynamic color'),
                          // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                          icon: const Icon(Icons.format_color_fill_rounded),
                          subtitle: const Text('Choose the accent color to emphasize certain elements'),
                          value: isDynamic,
                          onChanged: (value) => context.read<AppCubit>().updateDynamicColorMode(value),
                        );
                      },
                    ),
                    BlocSelector<AppCubit, AppState, (bool, int?)>(
                      selector: (state) => (state.isDynamicColor, state.accentColor),
                      builder: (context, state) {
                        final (isDynamic, accentColorInt) = state;
                        final accentColor = accentColorInt != null ? Color(accentColorInt) : context.colors.primary;
                        return SectionTile(
                          title: const Text('Accent color'),
                          // title: Text(context.watch<SettingsRepository>().currentLocale.name),
                          icon: const Icon(Icons.color_lens_rounded),
                          subtitle: const Text('Choose the accent color to emphasize certain elements'),
                          trailingIcon: CircleAvatar(
                            backgroundColor: isDynamic ? accentColor.withAlpha(120) : accentColor,
                          ),
                          onTap: () async {
                            final color = await InveslyColorPickerWidget.showModal(context, selectedColor: accentColor);
                            if (context.mounted && color != null) {
                              context.read<AppCubit>().updateAccentColor(color.toARGB32());
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
                          title: const Text('Dark mode'),
                          icon: const Icon(Icons.format_paint),
                          value: isDarkMode,
                          onChanged: (value) => context.read<AppCubit>().updateThemeMode(value),
                        );
                      },
                    ),
                  ],
                ),

                const Gap(16.0),

                // ~~~ Backup & Restore Section ~~~
                Section(
                  title: const Text('Backup & Restore'),
                  subTitle: const Text('Last backup: 2023-10-01'), // TODO: Update date
                  // icon: const Icon(Icons.import_export_rounded),
                  tiles: [
                    // ~ Import from CSV file ~
                    SectionTile.navigation(
                      icon: const Icon(Icons.restore_rounded),
                      title: const Text('Manual import'),
                      subtitle: const Text('Import transaction from a .csv file.'),
                      onTap: () => context.push(const ImportTransactionsScreen()),
                    ),

                    // ~ Export as CSV file ~
                    SectionTile(
                      title: const Text('Export transactions'),
                      icon: const Icon(Icons.backup_outlined),
                      subtitle: const Text('Export transactions locally as .csv file.'),
                      onTap: () => _onExportAsCsvPressed(context),
                    ),

                    // ~ Backup database locally ~
                    SectionTile(
                      title: Text('Backup locally'),
                      icon: const Icon(Icons.import_export_rounded),
                      subtitle: Text('This will create a new backup file in local storage.'),
                      onTap: () => _onBackupDatabasePressed(context),
                    ),

                    // ~ Restore database from local storage ~
                    SectionTile(
                      title: const Text('Restore from local storage'),
                      icon: const Icon(Icons.restore_page_outlined),
                      subtitle: const Text(
                        'Restore your data from a previously saved backup. This action will overwrite your current data.',
                      ),
                      onTap: () => _onRestoreFromDatabasePressed(context),
                    ),

                    // ~ Backup database to Google drive ~
                    SectionTile(
                      title: const Text('Backup to Google Drive'),
                      icon: const Icon(Icons.backup_outlined),
                      subtitle: const Text('Backup your data in a new backup file to Google Drive.'),
                      onTap: () => _onBackupToDrivePressed(context),
                    ),

                    // ~ Restore database from Google drive ~
                    SectionTile(
                      title: const Text('Restore from Google Drive'),
                      icon: const Icon(Icons.restore_page_outlined),
                      subtitle: const Text(
                        'Restore your data from a previously saved backup. This action will overwrite your current data.',
                      ),
                      onTap: () => _onRestoreFromDrivePressed(context),
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: const Text('Terms & Privacy'),
                  subTitle: const Text('Privacy policy, terms of service, etc.'),
                  // icon: const Icon(Icons.gavel_rounded),
                  tiles: [
                    SectionTile.navigation(
                      icon: const Icon(Icons.policy_outlined),
                      title: const Text('Privacy policy'),
                      subtitle: const Text('Read our privacy policy'),
                      onTap: () {},
                    ),
                    SectionTile.navigation(
                      icon: const Icon(Icons.gavel_rounded),
                      title: const Text('Terms of use'),
                      subtitle: const Text('Read our terms of use'),
                      onTap: () {},
                    ),
                  ],
                ),

                const Gap(16.0),

                Section(
                  title: const Text('Help us'),
                  subTitle: const Text('Thank you for your contribution to Invesly'),
                  tiles: [
                    SectionTile.navigation(
                      icon: const Icon(Icons.star_rate_rounded),
                      title: const Text('Rate us'),
                      subtitle: const Text('Rate us on the Play Store'),
                      onTap: () {},
                    ),
                    SectionTile.checkTile(
                      icon: const Icon(Icons.share_rounded),
                      title: const Text('Share with friends'),
                      subtitle: const Text('Share Invesly with your friends and family'),
                      onChanged: (value) {},
                      value: true,
                    ),
                    SectionTile(
                      icon: const Icon(Icons.feedback_outlined),
                      title: const Text('Feedback'),
                      subtitle: const Text('Report bugs, request features, or just say hi!'),
                      onTap: () {},
                    ),
                    SectionTile(
                      icon: const Icon(Icons.volunteer_activism_rounded),
                      title: const Text('Donate'),
                      subtitle: const Text('Support the development of Invesly'),
                      onTap: () {},
                    ),
                  ],
                ),

                const Gap(32.0),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onBackupToDrivePressed(BuildContext context) async {
    gapis.AccessToken? accessToken = context.read<AppCubit>().state.user?.gapiAccessToken;

    try {
      if (accessToken == null) {
        final user = await startLoginFlow(context, true);
        accessToken = user.gapiAccessToken;
        if (accessToken == null || !context.mounted) {
          $logger.w('Google sign-in failed'); //TODO: Show error message
          return;
        }
      }
      final file = BackupRepository.instance.databaseFile;
      // await context.read<AuthRepository>().saveFileInDrive(accessToken: accessToken, file: file);
      await AuthRepository.instance.saveFileInDrive(accessToken: accessToken, file: file);
      $logger.i('Backup created successfully');
    } catch (err) {
      $logger.e(err);
      if (err is gapis.AccessDeniedException && context.mounted) {
        await startLoginFlow(context, true);
      }
    }
  }

  Future<void> _onRestoreFromDrivePressed(BuildContext context) async {
    gapis.AccessToken? accessToken = context.read<AppCubit>().state.user?.gapiAccessToken;

    try {
      if (accessToken == null) {
        final user = await startLoginFlow(context);
        accessToken = user.gapiAccessToken;
        if (accessToken == null || !context.mounted) {
          $logger.e('Google sign-in failed');
          return;
        }
      }
    } catch (err) {
      $logger.e(err);
    }
    if (!context.mounted) return;
    DriveImportBackupPage.showModal(context);
  }

  Future<void> _onExportAsCsvPressed(BuildContext context) async {
    late final SnackBar snackBar;
    try {
      final csvData = await TransactionRepository.instance.transactionsToCsv();
      final file = await BackupRepository.instance.exportCsv(
        csvData,
        '/path/to/local/storage',
      ); // TODO: get path to storage
      if (file != null) {
        final fileName = basename(file.path);
        snackBar = SnackBar(
          content: Text('$fileName saved successfully to ${file.parent.path}'),
          backgroundColor: Colors.teal,
        );
      } else {
        snackBar = const SnackBar(content: Text('Error in saving file'), backgroundColor: Colors.deepOrange);
      }
    } catch (err) {
      $logger.e(err);
      snackBar = const SnackBar(content: Text('Error in saving file'), backgroundColor: Colors.deepOrange);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _onBackupDatabasePressed(BuildContext context) async {
    late final SnackBar snackBar;
    try {
      // String? path = await FilePicker.platform.getDirectoryPath();
      // if (path == null || path.isEmpty || !context.mounted) {
      //   return;
      // }

      final file = await BackupRepository.instance.exportDatabase();
      if (file != null) {
        snackBar = SnackBar(content: Text('File saved successfully, ${file.path}'), backgroundColor: Colors.teal);
      } else {
        snackBar = SnackBar(content: Text('Error in saving file'), backgroundColor: Colors.deepOrange);
      }
    } catch (err) {
      $logger.e(err);
      snackBar = SnackBar(content: Text('Error in saving file'), backgroundColor: Colors.deepOrange);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> _onRestoreFromDatabasePressed(BuildContext context) async {
    final backupRepo = BackupRepository.instance;
    try {
      final sourceFile = await backupRepo.selectDbFile();
      if (sourceFile == null || !context.mounted) {
        // TODO: Show error message - No file is selected
        return;
      }

      await showLoadingDialog<void>(context, () async {
        final fileContent = await backupRepo.getFileContentAsBytes(sourceFile);
        if (fileContent.isEmpty) {
          // TODO: Show error message - File is empty
          return;
        }

        await backupRepo.writeDatabase(fileContent);
      }); // TODO: implement loadingMessage: 'Restoring backup...'
      if (!context.mounted) {
        return;
      }
      await context.go(SplashPage());
    } catch (err) {
      // TODO: Show error message - General
      // await showAlertDialog(context, title: 'Error', content: '$err');
    }
  }
}
