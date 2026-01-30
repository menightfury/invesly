import 'package:flutter/material.dart';
import 'package:invesly/authentication/auth_ui_functions.dart';
import 'package:invesly/authentication/user_model.dart';

class GoogleSigninButton extends StatelessWidget {
  const GoogleSigninButton({super.key, this.onSigninComplete});

  final void Function(InveslyUser user)? onSigninComplete;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _onSignInPressed(context),
      icon: CircleAvatar(radius: 12.0, child: Image.asset('assets/images/google_logo.png')),
      label: const Text('Sign in with Google', textAlign: TextAlign.center),
    );
  }

  Future<void> _onSignInPressed(BuildContext context) async {
    final user = await startLoginFlow(context);
    onSigninComplete?.call(user);
  }
}
