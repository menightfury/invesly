// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ffi';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';

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
    _accessToken = context.read<SettingsCubit>().state.gapiAccessToken;
    _getDriveFiles(context);
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
                        child: OutlinedButton(onPressed: () {}, child: Text('Skip')),
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

            return GestureDetector(
              child: Text('No backup file found. Tap to return to dashboard.'),
              onTap: () => context.go(const DashboardScreen()),
            );
          }
          return Center(child: Column(children: <Widget>[CircularProgressIndicator(), Text('Looking for backups...')]));
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

  Future<void> _getDriveFiles(BuildContext context) async {
    final authRepository = context.read<AuthRepository>();
    try {
      // ignore: prefer_conditional_assignment
      if (_accessToken == null) {
        _accessToken = await openLoadingPopup<AccessToken>(context, () async {
          final user = await authRepository.signInWithGoogle();
          if (user == null) {
            throw Exception('Sign in failed');
          }

          final accessToken = await authRepository.getAccessToken(user);

          // Save access token to device
          if (context.mounted) {
            context.read<SettingsCubit>().saveGapiAccessToken(accessToken);
          }
          return accessToken;
        });
      }

      if (_accessToken == null) {
        throw Exception('Error getting accessToken');
      }

      if (!context.mounted) return;

      _files = context.read<AuthRepository>().getDriveFiles(_accessToken!);
    } catch (err) {
      $logger.e(err);
      throw Exception('Error getting drive files: $err');
    }
  }

  Future<void> _onRestorePressed(BuildContext context, drive.File file) async {
    final authRepository = context.read<AuthRepository>();

    // // Delete drive files -- Testing only
    // await authRepository.deleteBackups(accessToken);
    final fileContent = await authRepository.getDriveFileContent(accessToken: _accessToken!, fileId: file.id!);
    if (fileContent != null && fileContent.isNotEmpty) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text('Backup file found! Restoring your data...')));
    }

    await authRepository.writeDatabaseFile(fileContent);
    widget.onRestoreComplete?.call();
  }

  // Future<void> chooseBackup(
  //   BuildContext context, {
  //   bool isManaging = false,
  //   bool isClientSync = false,
  //   bool hideDownloadButton = false,
  // }) async {
  //   try {
  //     openBottomSheet(
  //       context,
  //       BackupManagement(isManaging: isManaging, isClientSync: isClientSync, hideDownloadButton: hideDownloadButton),
  //     );
  //   } catch (e) {
  //     popRoute(context);
  //     openSnackbar(SnackbarMessage(title: e.toString(), icon: Icons.error_rounded));
  //   }
  // }
}
