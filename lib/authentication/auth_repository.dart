import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/abusiveexperiencereport/v1.dart';
// import 'package:googleapis/adsense/v2.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/servicecontrol/v2.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:googleapis_auth/googleapis_auth.dart';

import 'package:invesly/database/invesly_api.dart';
import 'package:invesly/common_libs.dart';

// Future<bool> checkConnection() async {
//   late bool isConnected;
//   if (!kIsWeb) {
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         isConnected = true;
//       }
//     } on SocketException catch (e) {
//       $logger.e(e);
//       isConnected = false;
//     }
//   } else {
//     isConnected = true;
//   }
//   return isConnected;
// }

// enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

// Auth means Authentication and Authorization
class AuthRepository {
  AuthRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  // GoogleSignInAccount? googleUser;
  drive.DriveApi? _driveApi;

  final _googleSignIn = GoogleSignIn.instance;
  final _scopes = <String>[
    // See https://github.com/flutter/flutter/issues/155490 and https://github.com/flutter/flutter/issues/155429
    // Once an account is logged in with these scopes, they are not needed
    // So we will keep these to apply for all users to prevent errors, especially on silent sign in
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ];

  Future<GoogleSignInAccount?> signInWithGoogle({
    BuildContext? context,
    bool? waitForCompletion = false,
    Function()? next,
  }) async {
    // bool isConnected = false;
    // if (await checkLockedFeatureIfInDemoMode(context) == false) return null;

    try {
      // // Check connection
      // isConnected = await checkConnection().timeout(Duration(milliseconds: 2500),
      //     onTimeout: () {
      //   throw ("There was an error checking your connection");
      // });
      // if (isConnected == false) {
      //   if (context != null) {
      //     openSnackbar(context, "Could not connect to network",
      //       backgroundColor: Theme.of(context).colorScheme.error,
      //     );
      //   }
      //   return null;
      // }

      // if (waitForCompletion == true && context != null) openLoadingPopup(context);
      // if (googleUser == null) {

      await _googleSignIn.initialize(
        serverClientId: '791480731407-hc266q1klj0br5c9312gkjbsko05qjoq.apps.googleusercontent.com',
        // serverClientId: '791480731407-4j2dmhvu2l061j7g5odqelvg74bagu28.apps.googleusercontent.com', // Home
        // serverClientId: '791480731407-5k0kglrd6k78s11v4bkhnv473tva5862.apps.googleusercontent.com', // Office
      ); // TODO: Hide client Id
      return await _googleSignIn.authenticate();
      // return googleUser;

      // googleSignIn?.currentUser?.clearAuthCache();

      // if (googleUser != null) {
      //   await updateSettings('currentUserEmail', googleUser?.email ?? '', updateGlobalState: false);
      // } else {
      //   throw ("Login failed");
      // }

      // if (waitForCompletion == true && context != null) popRoute(context);
      // if (next != null) next();

      // await updateSettings('hasSignedIn', true, updateGlobalState: false);

      // refreshUIAfterLoginChange();
    } catch (err) {
      $logger.e(err);
      // if (waitForCompletion == true && context != null) popRoute(context);
      // openSnackbar(
      //   SnackbarMessage(
      //     title: 'sign-in-error',
      //     description: 'sign-in-error-description',
      //     icon: Icons.error_rounded,
      //     timeout: Duration(milliseconds: 3400),
      //     onTap: () => signInGoogle(
      //           context: context,
      //           next: next,
      //           silentSignIn: false,
      //           waitForCompletion: waitForCompletion,
      //         ),
      //   ),
      // );
      // googleUser = null;
      // await updateSettings("currentUserEmail", "", updateGlobalState: false);
      // if (runningCloudFunctions) {
      //   errorSigningInDuringCloud = true;
      // } else {
      // await updateSettings("hasSignedIn", false, updateGlobalState: false);
      // }
      throw ('Error signing in');
    }
  }

  Future<void> signOut() async {
    // Call disconnect rather than signOut to more fully reset the example app.
    await _googleSignIn.disconnect();
    // googleUser = null;
  }

  Future<AccessToken> getAccessToken(GoogleSignInAccount user) async {
    GoogleSignInClientAuthorization? authorization;

    try {
      // First check authorization without client interaction
      authorization = await user.authorizationClient.authorizationForScopes(_scopes);
      // If authorization is still null, request it interactively
      authorization ??= await user.authorizationClient.authorizeScopes(_scopes);

      return gapis.AccessToken(
        'Bearer',
        authorization.accessToken,
        // The underlying SDKs don't provide expiry information, so set an arbitrary distant-future time.
        DateTime.now().toUtc().add(const Duration(days: 365)),
      );
    } catch (err) {
      $logger.e(err);
      throw ('Error getting Access Token');
    }
  }
}
