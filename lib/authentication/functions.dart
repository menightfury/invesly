import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/authentication/user_model.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';

// Future<(GoogleSignInAccount, AccessToken)> startLoginFlow(BuildContext context) async {
Future<InveslyUser> startLoginFlow(BuildContext context) async {
  debugPrint('==== Signing in ====');
  // final authRepository = context.read<AuthRepository>();
  final authRepository = AuthRepository.instance;
  final appCubit = context.read<AppCubit>();

  late final AccessToken accessToken;

  try {
    // ignore: prefer_conditional_assignment
    final gAccount = await showLoadingDialog<GoogleSignInAccount?>(context, () async {
      final acc = await authRepository.signInWithGoogle();
      if (acc == null) {
        throw Exception('Sign in failed');
      }

      accessToken = await authRepository.getAccessToken(acc);
      // // Save access token to device
      // if (!context.mounted) {
      //   return null;
      // }
      // appCubit.updateGapiAccessToken(accessToken);
      return acc;
    });

    if (gAccount == null) {
      throw Exception('Sign in failed');
    }

    final user = InveslyUser(
      id: gAccount.id,
      email: gAccount.email,
      name: gAccount.displayName ?? gAccount.email,
      photoUrl: gAccount.photoUrl, // TODO: Cached network image and default avatar
      gapiAccessToken: accessToken,
    );
    // Save current user
    appCubit.updateUser(user);
    return user;
  } catch (err) {
    $logger.e(err);
    throw Exception('Error signing in');
  }
}

Future<void> startLogoutFlow(BuildContext context) async {
  debugPrint('==== Signing out ====');
  // final authRepository = context.read<AuthRepository>();
  final authRepository = AuthRepository.instance;
  final appCubit = context.read<AppCubit>();

  try {
    // ignore: prefer_conditional_assignment
    await showLoadingDialog<void>(context, () async {
      await authRepository.signOut();
      appCubit.updateUser(null);
    });
  } catch (err) {
    $logger.e(err);
    throw Exception('Error signing out');
  }
}
