// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:shimmer/shimmer.dart';

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/cubit/auth_cubit.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class ChooseBackupPage extends StatelessWidget {
  const ChooseBackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChooseBackupPage();
  }

  static Future<void> showModal(BuildContext context, [String? accountId]) async {
    return await showModalBottomSheet<void>(
      context: context,
      builder: (context) => const _ChooseBackupPage(showInModal: true),
    );
  }
}

class _ChooseBackupPage extends StatefulWidget {
  const _ChooseBackupPage({this.showInModal = false, super.key});

  final bool showInModal;

  @override
  State<_ChooseBackupPage> createState() => _ChooseBackupPageState();
}

class _ChooseBackupPageState extends State<_ChooseBackupPage> {
  late final Future<List<drive.File>?> _files;

  @override
  void initState() {
    super.initState();
    _files = _getDriveFiles(context);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<List<drive.File>?>(
        future: _files,
        builder: (context, asyncSnapshot) {
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

              // Restore button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _onRestorePressed(context),
                  icon: CircleAvatar(radius: 20.0, backgroundImage: AssetImage('assets/images/google_logo.png')),
                  label: Text('Restore', textAlign: TextAlign.center),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (!widget.showInModal) {
      content = Scaffold(
        appBar: AppBar(title: Text('Restore from Google drive')),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  Future<List<drive.File>?> _getDriveFiles(BuildContext context) async {
    final authRepository = context.read<AuthRepository>();
    AccessToken? accessToken = context.read<SettingsCubit>().state.gapiAccessToken;

    // ignore: prefer_conditional_assignment
    if (accessToken == null) {
      accessToken = await openLoadingPopup<AccessToken>(context, () async {
        final user = await authRepository.signInWithGoogle();
        if (user == null) {
          throw Exception('Sign in failed');
        }

        final accessToken = await authRepository.getAccessToken(user);

        // Save access token to device
        if (!context.mounted) return accessToken;
        context.read<SettingsCubit>().saveGapiAccessToken(accessToken);
        return accessToken;
      });
    }

    if (accessToken == null) {
      throw Exception('Error getting accessToken');
    }

    if (!context.mounted) return null;

    return await context.read<AuthRepository>().getDriveFiles(accessToken);
  }

  void _onRestorePressed(BuildContext context) async {
    final authRepository = context.read<AuthRepository>();

    List<int>? fileContent;
    // // Delete drive files -- Testing only
    // await authRepository.deleteBackups(accessToken);

    if (files != null && files.isNotEmpty) {
      // Show popup to choose backup

      fileContent = await authRepository.getDriveFileContent(accessToken: accessToken, fileId: files.first.id!);
      if (fileContent != null && fileContent.isNotEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup file found! Restoring your data...')));
      }
    }
    await authRepository.writeDatabaseFile(fileContent);
  }

  Future<void> chooseBackup(
    BuildContext context, {
    bool isManaging = false,
    bool isClientSync = false,
    bool hideDownloadButton = false,
  }) async {
    try {
      openBottomSheet(
        context,
        BackupManagement(isManaging: isManaging, isClientSync: isClientSync, hideDownloadButton: hideDownloadButton),
      );
    } catch (e) {
      popRoute(context);
      openSnackbar(SnackbarMessage(title: e.toString(), icon: Icons.error_rounded));
    }
  }
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
      child: Padding(
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
    );
  }
}
