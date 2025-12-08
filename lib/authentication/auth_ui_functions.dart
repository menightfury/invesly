import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';

Future<InveslyUser> startLoginFlow(BuildContext context, [bool forceLogin = false]) async {
  debugPrint('==== Signing in ====');
  // Check if already signed in and not forced to sign in again
  InveslyUser? user = context.read<AppCubit>().state.user;
  if (user != null && !forceLogin) {
    return Future.value(user);
  }

  final authRepository = AuthRepository.instance;
  late final AccessToken accessToken;

  try {
    // ignore: prefer_conditional_assignment
    final gAccount = await showLoadingDialog<GoogleSignInAccount?>(context, () async {
      final acc = await authRepository.signInWithGoogle();
      if (acc == null) {
        throw Exception('Sign in failed');
      }
      accessToken = await authRepository.getAccessToken(acc);
      return acc;
    });

    if (gAccount == null) {
      throw Exception('Sign in failed');
    }

    user = InveslyUser(
      id: gAccount.id,
      email: gAccount.email,
      name: gAccount.displayName ?? gAccount.email.substring(0, gAccount.email.indexOf('@')),
      photoUrl: gAccount.photoUrl,
      gapiAccessToken: accessToken,
    );
    // Save current user
    if (context.mounted) {
      context.read<AppCubit>().updateUser(user);
    }

    return user;
  } catch (err) {
    $logger.e(err);
    throw Exception('Error signing in');
  }
}

Future<void> startLogoutFlow(BuildContext context) async {
  debugPrint('==== Signing out ====');
  // Check if already signed in
  final user = context.read<AppCubit>().state.user;
  if (user == null) {
    return;
  }

  final authRepository = AuthRepository.instance;
  try {
    // ignore: prefer_conditional_assignment
    await showLoadingDialog<void>(context, () async {
      await authRepository.signOut();
      if (context.mounted) {
        context.read<AppCubit>().updateUser(null);
      }
    });
  } catch (err) {
    $logger.e(err);
    throw Exception('Error signing out');
  }
}
