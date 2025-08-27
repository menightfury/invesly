// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/common_libs.dart';
import 'package:invesly/settings/cubit/settings_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.onComplete});

  final void Function(BuildContext context)? onComplete;

  @override
  Widget build(BuildContext context) {
    return _LoginPage(key: key, onComplete: onComplete);
  }

  static Future<void> showModal(
    BuildContext context, {
    Key? key,
    void Function(BuildContext context)? onComplete,
  }) async {
    return await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return _LoginPage(key: key, showInModal: true, onComplete: onComplete);
      },
    );
  }
}

class _LoginPage extends StatefulWidget {
  const _LoginPage({super.key, this.showInModal = false, this.onComplete});

  final bool showInModal;
  final void Function(BuildContext context)? onComplete;

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

    await openLoadingPopup(context, () async {
      final user = await authRepository.signInWithGoogle();
      if (user == null) {
        throw Exception('Sign in failed');
      }

      final accessToken = await authRepository.getAccessToken(user);

      // Save access token to device
      if (!context.mounted) return;
      context.read<SettingsCubit>().saveGapiAccessToken(accessToken);
    });

    if (!context.mounted) return;
    widget.onComplete?.call(context);
  }
}
