// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:google_sign_in/google_sign_in.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:shimmer/shimmer.dart';

import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/cubit/auth_cubit.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';
import 'package:invesly/transactions/dashboard/view/dashboard_screen.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(repository: context.read<AuthRepository>()),
      child: const _LoginPage(),
    );
  }

  static Future<void> showModal(BuildContext context, [String? accountId]) async {
    return await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return BlocProvider(
          create: (context) => AuthCubit(repository: context.read<AuthRepository>()),
          child: const _LoginPage(showInModal: true),
        );
      },
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({this.showInModal = false, super.key});

  final bool showInModal;

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: <Widget>[
          // Welcome text
          Text('Welcome to Invesly!', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
          Text('Let’s login for explore continues', style: context.textTheme.labelMedium?.copyWith(color: Colors.grey)),
          Spacer(),

          // Sign in button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _onSignInPressed(context),
              icon: CircleAvatar(radius: 20.0, backgroundImage: AssetImage('assets/images/google_logo.png')),
              label: Text('Sign in with Google', textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );

    if (!widget.showInModal) {
      content = Scaffold(
        appBar: AppBar(title: Text('Login with google')),
        body: SafeArea(child: content),
      );
    }

    return content;
  }

  void _onSignInPressed(BuildContext context) async {
    final authRepository = context.read<AuthRepository>();
    // openLoadingPopup(context, () async {
    //   final user = await authRepository.signInWithGoogle();
    //   if (user != null) {
    //     final accessToken = await authRepository.getAccessToken(user);

    //     // Save access token to device
    //     if (!context.mounted) return;
    //     context.read<SettingsCubit>().saveGapiAccessToken(accessToken);

    //     // Get Google Drive files
    //     final fileContent = await authRepository.getDriveFileContent(accessToken);
    //     $logger.i('File content: $fileContent');
    //     if (fileContent != null && fileContent.isNotEmpty) {
    //       ScaffoldMessenger.of(
    //         context,
    //       ).showSnackBar(const SnackBar(content: Text('Backup file found! Restoring your data...')));
    //       // Copy the latest backup file to the device
    //     }
    //     await authRepository.writeDatabaseFile(fileContent);
    //   }
    // }, onSuccess: (_) => context.push(const DashboardScreen()));
    context.push(const DashboardScreen());
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
      baseColor: Theme.of(context).colorScheme.secondaryContainer,
      highlightColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
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
