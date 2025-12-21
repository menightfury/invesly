// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/auth_ui_functions.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_repository.dart';
import 'package:invesly/intro/splash_page.dart';

class DriveImportBackupPage extends StatelessWidget {
  const DriveImportBackupPage({super.key, this.onComplete});

  final ValueChanged<bool?>? onComplete;

  @override
  Widget build(BuildContext context) {
    return _DriveImportBackupPage(key: key, onComplete: onComplete);
  }

  static Future<bool?> showModal(BuildContext context, {Key? key}) async {
    return await showModalBottomSheet<bool>(
      context: context,
      // isDismissible: false,
      // enableDrag: false,
      useSafeArea: true,
      builder: (context) {
        return _DriveImportBackupPage(key: key, showInModal: true, onComplete: (value) => context.pop(value));
      },
    );
  }
}

class _DriveImportBackupPage extends StatefulWidget {
  const _DriveImportBackupPage({super.key, this.showInModal = false, this.onComplete});

  final bool showInModal;
  final ValueChanged<bool>? onComplete;

  @override
  State<_DriveImportBackupPage> createState() => _DriveImportBackupPageState();
}

class _DriveImportBackupPageState extends State<_DriveImportBackupPage> {
  late final Future<List<drive.File>?> _files;
  AccessToken? _accessToken;

  @override
  void initState() {
    super.initState();
    _accessToken = context.read<AppCubit>().state.user?.gapiAccessToken;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _files = _getDriveFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      spacing: 8.0,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          child: Text(
            'Restore from Google Drive',
            style: TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FutureBuilder<List<drive.File>?>(
              future: _files,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final files = snapshot.data;
                  if (files == null || files.isEmpty) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 12.0,
                      children: <Widget>[
                        Image.asset('assets/images/empty_1.png', height: 200.0),
                        const Text('Sorry! No backup found.', textAlign: TextAlign.center),
                        Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(onPressed: () => _onSkipPressed(context), child: const Text('Dismiss')),
                        ),
                      ],
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
                  return Column(
                    children: <Widget>[
                      Icon(Icons.cloud_done_rounded, size: 48.0, color: context.theme.primaryColor),
                      const Gap(8.0),
                      const Text('Backup found!', style: TextStyle(fontWeight: FontWeight.w600)),
                      if (file.modifiedTime != null)
                        Text(
                          file.modifiedTime!.toReadable(),
                          style: context.textTheme.labelMedium?.copyWith(color: Colors.grey),
                        ),

                      if (file.size != null && int.tryParse(file.size!) != null)
                        Text(
                          'Size: ${int.parse(file.size!).formatAsBytes(2)}',
                          style: context.textTheme.labelMedium?.copyWith(color: Colors.grey),
                        ),
                      Spacer(),

                      // Restore button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          spacing: 8.0,
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _onSkipPressed(context),
                                child: const Text('Skip'),
                              ),
                            ),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _onRestorePressed(context, file),
                                icon: Icon(Icons.restore_rounded),
                                label: const Text('Restore', textAlign: TextAlign.center),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12.0,
                    children: <Widget>[
                      SpinKitDancingSquare(color: context.theme.primaryColor),
                      const Text('Looking for backups...'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    if (!widget.showInModal) {
      content = Scaffold(
        appBar: AppBar(title: Text('Import from Google drive')),
        body: SafeArea(
          child: Padding(padding: const EdgeInsets.all(16.0), child: content),
        ),
      );
    }

    return content;
  }

  Future<List<drive.File>?> _getDriveFiles(BuildContext context) async {
    try {
      if (_accessToken == null) {
        final user = await startLoginFlow(context);
        _accessToken = user.gapiAccessToken;
        if (_accessToken == null || !context.mounted) {
          throw Exception('Google sign-in failed');
        }
      }
      return await AuthRepository.instance.getDriveFiles(_accessToken!);
    } catch (err) {
      $logger.e(err);
      if (err is gapis.AccessDeniedException && context.mounted) {
        await startLoginFlow(context, true);
      }
      if (!context.mounted) return null;
      return await _getDriveFiles(context);
    }
  }

  Future<void> _onSkipPressed(BuildContext context) async {
    widget.onComplete?.call(false);
  }

  Future<void> _onRestorePressed(BuildContext context, drive.File file) async {
    widget.onComplete?.call(true);

    try {
      await showLoadingDialog<void>(context, () async {
        // // Delete drive files -- Testing only
        // await authRepository.deleteBackups(accessToken);
        final fileContent = await AuthRepository.instance.getDriveFileContent(
          accessToken: _accessToken!,
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
      await context.go(SplashPage());
    } catch (err) {
      $logger.e(err);
      // await showAlertDialog(context, title: 'Error', content: '$err');
    }
  }
}
