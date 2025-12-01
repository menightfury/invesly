import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:invesly/authentication/auth_repository.dart';
import 'package:invesly/common/cubit/app_cubit.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';

Future<(GoogleSignInAccount, AccessToken)> startLoginFlow(BuildContext context) async {
  // final authRepository = context.read<AuthRepository>();
  final authRepository = AuthRepository.instance;

  // GoogleSignInAccount? user;
  late final AccessToken accessToken;

  try {
    // ignore: prefer_conditional_assignment
    final user = await showLoadingDialog<GoogleSignInAccount?>(context, () async {
      final user_ = await authRepository.signInWithGoogle();
      if (user_ == null) {
        throw Exception('Sign in failed');
      }

      accessToken = await authRepository.getAccessToken(user_);

      // Save access token to device
      if (!context.mounted) return null;
      context.read<AppCubit>().updateGapiAccessToken(accessToken);

      return user_;
    });

    if (user == null) {
      throw Exception('Sign in failed');
    }

    return (user, accessToken);
  } catch (err) {
    $logger.e(err);
    throw Exception('Error signing in');
  }
}
