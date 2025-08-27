// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';
import 'package:shimmer/shimmer.dart';

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
                  Text('Backup found!', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                  Text(
                    'Restore your data from Google Drive',
                    style: context.textTheme.labelMedium?.copyWith(color: Colors.grey),
                  ),
                  Spacer(),

                  LoadingShimmerDriveFiles(isManaging: true, i: 5),

                  // Restore button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          // ScaffoldMessenger.of(
                          //   context,
                          // ).showSnackBar(const SnackBar(content: Text('No backup file found!')));
                          return;
                        }
                        _onRestorePressed(context, snapshot.data!.first);
                      },
                      icon: CircleAvatar(radius: 20.0, backgroundImage: AssetImage('assets/images/google_logo.png')),
                      label: Text('Restore', textAlign: TextAlign.center),
                    ),
                  ),
                ],
              );
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return GestureDetector(
              child: LoadingShimmerDriveFiles(isManaging: true, i: 3),
              onTap: () => context.go(const DashboardScreen()),
            );
          }
          return Center(child: CircularProgressIndicator());
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

class LoadingShimmerDriveFiles extends StatelessWidget {
  const LoadingShimmerDriveFiles({super.key, required this.isManaging, required this.i});

  final bool isManaging;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      // period: Duration(milliseconds: (1000 + randomDouble[i % 10] * 520).toInt()),
      period: Duration(milliseconds: (1000 + 0.5 * 520).toInt()),
      baseColor: context.colors.secondaryContainer,
      highlightColor: context.colors.secondaryContainer.withOpacity(0.2),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: Tappable(
              onTap: () {},
              // borderRadius: 15,
              // color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
              content: Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.description_rounded, color: Theme.of(context).colorScheme.secondary, size: 30),
                          SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadiusDirectional.all(Radius.circular(5)),
                                    color: Colors.white,
                                  ),
                                  height: 20,
                                  // width: 70 + randomDouble[i % 10] * 120 + 13,
                                  width: 70 + 0.5 * 120 + 13,
                                ),
                                SizedBox(height: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadiusDirectional.all(Radius.circular(5)),
                                    color: Colors.white,
                                  ),
                                  height: 14,
                                  // width: 90 + randomDouble[i % 10] * 120,
                                  width: 90 + 0.9 * 120,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 13),
                    isManaging
                        ? Row(
                            children: [
                              IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
                              SizedBox(width: 5),
                              IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10.0, width: 300),
        ],
      ),
    );
  }
}
