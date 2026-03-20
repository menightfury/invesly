// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:googleapis/businessprofileperformance/v1.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/auth_ui_functions.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/components/google_signin_button.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/dashboard/view/dashboard_page.dart';
import 'package:invesly/database/backup/backup_repository.dart';

class RestoreDriveBackupPage extends StatelessWidget {
  const RestoreDriveBackupPage({super.key, this.onComplete});

  final ValueChanged<bool?>? onComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore from Google drive'),
        actions: [
          if (!context.canPop)
            InkWell(
              onTap: () => _finalizeSetup(context),
              child: Padding(padding: const EdgeInsets.all(2.0), child: const Text('Skip')),
            ),
        ],
        actionsPadding: const EdgeInsets.only(right: 16.0),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16.0,
              children: <Widget>[
                // ~ Current user or Google signin button
                BlocSelector<AppCubit, AppState, InveslyUser?>(
                  selector: (state) => state.user,
                  builder: (context, currentUser) {
                    // final user = currentUser ?? InveslyUser.empty();
                    if (currentUser.isNullOrEmpty) {
                      return GoogleSigninButton();
                    }
                    return SectionTile(
                      title: Text(currentUser.isNotNullOrEmpty ? currentUser!.name.toSentenceCase() : 'Investor'),
                      subtitle: currentUser.isNotNullOrEmpty ? Text(currentUser?.email ?? 'e-mail: NA') : null,
                      icon: currentUser.isNotNullOrEmpty
                          ? InveslyUserCircleAvatar(user: currentUser!)
                          : CircleAvatar(child: const Icon(Icons.person_rounded)),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: context.colors.outlineVariant),
                        borderRadius: iCardBorderRadius,
                      ),
                      tileColor: context.colors.surface,
                      padding: const EdgeInsets.all(16.0),
                      trailingIcon: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          minimumSize: const Size(0.0, 0.0),
                        ),
                        onPressed: () async {
                          await startLogoutFlow(context);
                          // if (!context.mounted) return;
                          // await startLoginFlow(context);
                        },
                        child: Text('Sign out', style: context.textTheme.bodySmall),
                      ),
                    );
                  },
                ),
                BlocSelector<AppCubit, AppState, InveslyUser?>(
                  selector: (state) => state.user,
                  builder: (context, user) {
                    if (user.isNullOrEmpty) {
                      return Text('Please login to see drive backups');
                    }
                    if (user!.gapiAccessToken == null) {
                      return Text('Error getting access token! Please re-login');
                    }
                    return Expanded(
                      child: _DriveFiles(accessToken: user.gapiAccessToken!, onComplete: () => _finalizeSetup(context)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _finalizeSetup(BuildContext context) {
    context.read<AppCubit>().updateLastRestoreDate(DateTime.now());
    context.go(const DashboardPage());
  }
}

class _DriveFiles extends StatefulWidget {
  const _DriveFiles({super.key, required this.accessToken, this.onComplete});

  final VoidCallback? onComplete;
  final AccessToken accessToken;

  @override
  State<_DriveFiles> createState() => _DriveFilesState();
}

class _DriveFilesState extends State<_DriveFiles> {
  late Future<List<drive.File>?> _files;
  // late final AccessToken _accessToken;
  late final ValueNotifier<drive.File?> _selectedFile;

  @override
  void initState() {
    super.initState();
    _files = _getDriveFiles(context);
    // _accessToken = widget.accessToken;
    _selectedFile = ValueNotifier(null);
  }

  @override
  void didUpdateWidget(covariant _DriveFiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.accessToken != oldWidget.accessToken) {
      _files = _getDriveFiles(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<drive.File>?>(
      future: _files,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: context.colors.error),
                textAlign: TextAlign.center,
              ),
            );
          }

          final files = snapshot.data;
          // ~ No files found
          if (files == null || files.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16.0,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(color: context.colors.surfaceContainerLow, shape: BoxShape.circle),
                    child: Icon(Icons.cloud_off_rounded, size: 48.0, color: context.colors.outline),
                  ),
                  Text(
                    'No backups found',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
            );
          }

          List<drive.File> recentFiles = files;
          if (files.length > 1) {
            final sorted = files.where((file) => file.modifiedTime != null).toList()
              ..sort((a, b) => b.modifiedTime!.compareTo(a.modifiedTime!));
            recentFiles = sorted.take(5).toList();
          }
          return Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    PhysicalModel(
                      shape: BoxShape.circle,
                      color: context.colors.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.cloud_done_rounded, size: 32.0, color: context.colors.onPrimaryContainer),
                      ),
                    ),
                    const Gap(16.0),

                    Text('Backup Found', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Gap(4.0),

                    Text(
                      'The following backup files have been found in your Google Drive.',
                      style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(24.0),

                    Expanded(
                      child: ValueListenableBuilder<drive.File?>(
                        valueListenable: _selectedFile,
                        builder: (context, selectedFile, child) {
                          return Section.builder(
                            margin: EdgeInsets.zero,
                            tileCount: recentFiles.length,
                            tileBuilder: (context, index) {
                              final file = recentFiles[index];
                              return SectionTile.checkTile(
                                title: FormattedDate(
                                  date: file.modifiedTime ?? file.createdTime ?? DateTime.now(),
                                  style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                subtitle: file.size != null && int.tryParse(file.size!) != null
                                    ? Text(int.parse(file.size!).formatAsBytes(2))
                                    : const Text('...'),
                                value: selectedFile == file,
                                onChanged: (isSelected) => _selectedFile.value = isSelected ? file : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ValueListenableBuilder<drive.File?>(
                  valueListenable: _selectedFile,
                  builder: (context, selectedFile, child) {
                    return FilledButton.icon(
                      onPressed: selectedFile != null ? () => _onRestorePressed(context, selectedFile) : null,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore Backup'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.all(16.0)),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16.0,
            children: <Widget>[
              CircularProgressIndicator(strokeCap: StrokeCap.round),
              Text(
                'Searching for backups...',
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<drive.File>?> _getDriveFiles(BuildContext context) async {
    try {
      // if (_accessToken == null) {
      //   final user = await startLoginFlow(context);
      //   _accessToken = user.gapiAccessToken;
      //   if (_accessToken == null || !context.mounted) {
      //     throw Exception('Google sign-in failed');
      //   }
      // }
      return await AuthRepository.instance.getDriveFiles(widget.accessToken);
    } catch (err) {
      $logger.e(err.runtimeType);
      if (err is gapis.AccessDeniedException && context.mounted) {
        await startLoginFlow(context, true);
      }
      if (!context.mounted) return null;
      return await _getDriveFiles(context);
    }
  }

  // void _onSkipPressed(BuildContext context) {
  //   // widget.onComplete?.call(false);
  //   _finalizeSetup();
  // }

  Future<void> _onRestorePressed(BuildContext context, drive.File file) async {
    // widget.onComplete?.call(true);

    try {
      await showLoadingDialog<void>(context, () async {
        // ! Delete drive files -- Testing only
        // await authRepository.deleteBackups(accessToken);
        final fileContent = await AuthRepository.instance.getDriveFileContent(
          accessToken: widget.accessToken,
          fileId: file.id!,
        );
        if (fileContent == null || fileContent.isEmpty) {
          throw Exception('Error reading backup file from Google Drive.');
        }
        await BackupRepository.instance.writeDatabase(fileContent);
      }); // TODO: implement loadingMessage: 'Restoring backup...'
      if (!context.mounted) {
        return;
      }
      // await context.go(SplashPage());
      widget.onComplete?.call();
    } catch (err) {
      $logger.e(err);
      // await showAlertDialog(context, title: 'Error', content: '$err');
    }
  }

  // void _finalizeSetup() {
  //   // widget.onComplete?.call(true);
  //   context.go(const DashboardPage());
  // }
}
