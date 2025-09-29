// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/login_page.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/database/backup/backup_service.dart';
import 'package:invesly/common/cubit/app_cubit.dart';

class ImportBackupPage extends StatelessWidget {
  const ImportBackupPage({super.key, this.onRestoreComplete});

  final VoidCallback? onRestoreComplete;

  @override
  Widget build(BuildContext context) {
    return _ImportBackupPage(key: key, onRestoreComplete: onRestoreComplete);
  }

  static Future<void> showModal(BuildContext context, {Key? key}) async {
    return await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (context) {
        return _ImportBackupPage(key: key, showInModal: true, onRestoreComplete: () => context.pop());
      },
    );
  }
}

class _ImportBackupPage extends StatefulWidget {
  const _ImportBackupPage({super.key, this.showInModal = false, this.onRestoreComplete});

  final bool showInModal;
  final VoidCallback? onRestoreComplete;

  @override
  State<_ImportBackupPage> createState() => _ImportBackupPageState();
}

class _ImportBackupPageState extends State<_ImportBackupPage> {
  late final Future<List<drive.File>?> _files;
  AccessToken? _accessToken;

  @override
  void initState() {
    super.initState();
    _accessToken = context.read<AppCubit>().state.gapiAccessToken;
    _files = _getDriveFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<drive.File>?>(
        future: _files,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.0,
                children: <Widget>[
                  // Welcome text
                  Text('Restore backup', style: context.textTheme.headlineMedium),
                  Gap(8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Icon(Icons.cloud_done, size: 48.0, color: Colors.teal),
                  ),
                  Text('Backup found!', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                  Gap(8.0),
                  Text('6 minutes ago', style: context.textTheme.labelMedium?.copyWith(color: Colors.grey)),
                  Text('Size: 215 KB', style: context.textTheme.labelMedium?.copyWith(color: Colors.grey)),
                  Gap(16.0),
                  Text(
                    'Restore your data from Google Drive. If you don\'t restore now, you won\'t be able to restore it later.',
                  ),
                  Spacer(),

                  // Restore button
                  Row(
                    spacing: 8.0,
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(onPressed: () => widget.onRestoreComplete?.call(), child: Text('Skip')),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return;
                            }
                            _onRestorePressed(context, snapshot.data!.first);
                          },
                          icon: Icon(Icons.restore_rounded),
                          label: Text('Restore', textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: <Widget>[
                Image.asset('assets/images/empty_1.png', height: 200),
                Text('Sorry! No backup found.', textAlign: TextAlign.center),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onRestoreComplete?.call(),
                    child: Text('Go to dashboard'),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: Column(
              spacing: 8.0,
              children: <Widget>[CircularProgressIndicator(), Text('Looking for backups...')],
            ),
          );
        },
      ),
    );

    if (!widget.showInModal) {
      content = Scaffold(
        appBar: AppBar(title: Text('Import from Google drive')),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  Future<List<drive.File>?> _getDriveFiles(BuildContext context) async {
    try {
      // // ignore: prefer_conditional_assignment
      if (_accessToken == null) {
        final (_, accessToken_) = await LoginPage.startLoginFlow(context);
        _accessToken = accessToken_;
      }
      // if (accessToken_ == null) {
      //   throw Exception('Error getting accessToken');
      // }

      if (!context.mounted) return null;
      return await context.read<AuthRepository>().getDriveFiles(_accessToken!);
    } catch (err) {
      $logger.e(err);
      throw Exception('Error getting drive files: $err');
    }
  }

  Future<void> _onRestorePressed(BuildContext context, drive.File file) async {
    final authRepository = context.read<AuthRepository>();
    final backupRepository = context.read<BackupRestoreRepository>();

    // // Delete drive files -- Testing only
    // await authRepository.deleteBackups(accessToken);
    final fileContent = await authRepository.getDriveFileContent(accessToken: _accessToken!, fileId: file.id!);
    await backupRepository.writeDatabaseFile(fileContent);
    widget.onRestoreComplete?.call();
  }
}
