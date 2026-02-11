// ignore_for_file: public_member_api_docs, sort_constructors_first

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
              onTap: () => context.go(const DashboardPage()),
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
                BlocSelector<AppCubit, AppState, InveslyUser?>(
                  selector: (state) => state.user,
                  builder: (context, currentUser) {
                    // final user = currentUser ?? InveslyUser.empty();
                    if (currentUser.isNullOrEmpty) {
                      return GoogleSigninButton();
                    }
                    return Column(
                      children: <Widget>[
                        SectionTile(
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
                        ),
                      ],
                    );
                  },
                ),
                BlocSelector<AppCubit, AppState, InveslyUser?>(
                  selector: (state) => state.user,
                  builder: (context, user) {
                    if (user.isNullOrEmpty || user!.gapiAccessToken == null) {
                      return Text('Please login to see drive backups');
                    }
                    return Expanded(child: _DriveFiles(accessToken: user.gapiAccessToken!));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriveFiles extends StatefulWidget {
  const _DriveFiles({super.key, required this.accessToken});

  // final ValueChanged<bool>? onComplete;
  final AccessToken accessToken;

  @override
  State<_DriveFiles> createState() => _DriveFilesState();
}

class _DriveFilesState extends State<_DriveFiles> {
  late final Future<List<drive.File>?> _files;
  late final AccessToken _accessToken;

  @override
  void initState() {
    super.initState();
    _accessToken = widget.accessToken;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _files = _getDriveFiles(context);
  }

  @override
  void didUpdateWidget(covariant _DriveFiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    _files = _getDriveFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<drive.File>?>(
      future: _files,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: context.colors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final files = snapshot.data;
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

          // find the most recent backup file
          final file = files.length > 1
              ? files.reduce((a, b) {
                  final aTime = a.modifiedTime ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final bTime = b.modifiedTime ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return aTime.isAfter(bTime) ? a : b;
                })
              : files.first;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: context.colors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(color: context.colors.primaryContainer, shape: BoxShape.circle),
                        child: Icon(Icons.cloud_done_rounded, size: 32.0, color: context.colors.onPrimaryContainer),
                      ),
                      const Gap(16.0),
                      Text('Backup Found', style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Gap(4.0),
                      Text(
                        'We found a backup file in your Google Drive.',
                        style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(24.0),
                      Divider(height: 1, color: context.colors.outlineVariant),
                      const Gap(16.0),
                      _buildInfoRow(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Last Modified',
                        valueWidget: file.modifiedTime != null
                            ? FormattedDate(
                                date: file.modifiedTime!,
                                style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              )
                            : Text('-', style: context.textTheme.bodyMedium),
                      ),
                      const Gap(12.0),
                      _buildInfoRow(
                        context,
                        icon: Icons.sd_storage_rounded,
                        label: 'Size',
                        valueWidget: Text(
                          file.size != null && int.tryParse(file.size!) != null
                              ? int.parse(file.size!).formatAsBytes(2)
                              : '-',
                          style: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    // Expanded(
                    //   child: TextButton(
                    //     onPressed: () => _onSkipPressed(context),
                    //     style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                    //     child: Text('Skip', style: TextStyle(color: context.colors.onSurfaceVariant)),
                    //   ),
                    // ),
                    // const Gap(16.0),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: () => _onRestorePressed(context, file),
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Restore Backup'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      return await AuthRepository.instance.getDriveFiles(_accessToken);
    } catch (err) {
      $logger.e(err);
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
        // // Delete drive files -- Testing only
        // await authRepository.deleteBackups(accessToken);
        final fileContent = await AuthRepository.instance.getDriveFileContent(
          accessToken: _accessToken,
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
      _finalizeSetup();
    } catch (err) {
      $logger.e(err);
      // await showAlertDialog(context, title: 'Error', content: '$err');
    }
  }

  void _finalizeSetup() {
    // widget.onComplete?.call(true);
    context.go(const DashboardPage());
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.0, color: context.colors.onSurfaceVariant),
        const Gap(12.0),
        Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
        const Spacer(),
        valueWidget,
      ],
    );
  }
}
