import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/abusiveexperiencereport/v1.dart';
// import 'package:googleapis/adsense/v2.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/servicecontrol/v2.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;
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
  // Singleton pattern
  AuthRepository._()
    : _googleSignIn = GoogleSignIn.instance,
      _scopes = const <String>[
        // See https://github.com/flutter/flutter/issues/155490 and https://github.com/flutter/flutter/issues/155429
        // Once an account is logged in with these scopes, they are not needed
        // So we will keep these to apply for all users to prevent errors, especially on silent sign in
        'https://www.googleapis.com/auth/userinfo.profile',
        'https://www.googleapis.com/auth/userinfo.email',
        drive.DriveApi.driveAppdataScope,
        drive.DriveApi.driveFileScope,
      ];
  factory AuthRepository.initialize() => _instance;
  static final AuthRepository _instance = AuthRepository._();
  static AuthRepository get instance => _instance;

  // GoogleSignInAccount? googleUser;
  drive.DriveApi? _driveApi;

  final GoogleSignIn _googleSignIn;
  final List<String> _scopes;

  Future<GoogleSignInAccount?> signInWithGoogle({bool? waitForCompletion = false, Function()? next}) async {
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

  Future<gapis.AccessToken> getAccessToken(GoogleSignInAccount user) async {
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

  Future<drive.DriveApi> getDriveApi(gapis.AccessToken accessToken) async {
    try {
      final credentials = gapis.AccessCredentials(
        accessToken,
        null, // The underlying SDKs don't provide a refresh token.
        _scopes,
      );
      final client = gapis.authenticatedClient(http.Client(), credentials);
      // final client = authorization.authClient(scopes: _scopes);

      return _driveApi = drive.DriveApi(client);
    } catch (err) {
      $logger.e(err);
      throw ('Error getting Drive API');
    }
  }

  Future<List<drive.File>?> getDriveFiles(gapis.AccessToken accessToken) async {
    try {
      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, modifiedTime, size)',
      );
      final files = fileList.files;
      $logger.i(files);
      if (files == null || files.isEmpty) {
        return null;
      }
      return files;
    } catch (err) {
      $logger.e(err);
      // if (err is DetailedApiRequestError && err.status == 401) {
      //   // await refreshGoogleSignIn();
      //   return await getDriveFiles();
      // } else if (err is PlatformException) {
      //   // await refreshGoogleSignIn();
      //   return await getDriveFiles();
      // } else {
      //   // openSnackbar(SnackbarMessage(title: e.toString(), icon: Icons.error_rounded));
      // }
    }
    return null;
  }

  Future<List<int>?> getDriveFileContent({required gapis.AccessToken accessToken, required String fileId}) async {
    try {
      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final List<int> dataStore = [];
      // media.stream.listen(
      //   (data) => dataStore.insertAll(dataStore.length, data),
      //   onError: (err) => $logger.e('Error :$err'),
      // );
      await for (var data in media.stream) {
        dataStore.insertAll(dataStore.length, data);
      }
      
      return dataStore;
    } catch (err) {
      $logger.e(err);
      // if (err is DetailedApiRequestError && err.status == 401) {
      //   // await refreshGoogleSignIn();
      //   return await getDriveFiles();
      // } else if (err is PlatformException) {
      //   // await refreshGoogleSignIn();
      //   return await getDriveFiles();
      // } else {
      //   // openSnackbar(SnackbarMessage(title: e.toString(), icon: Icons.error_rounded));
      // }
    }
    return null;
  }

  // Future<void> loadBackup(BuildContext context, DriveApi driveApi, File file) async {
  //   try {
  //     openLoadingPopup(context);

  //     await cancelAndPreventSyncOperation();

  //     List<int> dataStore = [];
  //     dynamic response = await driveApi.files.get(file.id ?? "", downloadOptions: drive.DownloadOptions.fullMedia);
  //     response.stream.listen(
  //       (data) {
  //         // print("Data: ${data.length}");
  //         dataStore.insertAll(dataStore.length, data);
  //       },
  //       onDone: () async {
  //         await overwriteDefaultDB(Uint8List.fromList(dataStore));

  //         // if this is added, it doesn't restore the database properly on web
  //         // await database.close();
  //         popRoute(context);
  //         await resetLanguageToSystem(context);
  //         await updateSettings("databaseJustImported", true, pagesNeedingRefresh: [], updateGlobalState: false);
  //         // openSnackbar(
  //         //   SnackbarMessage(
  //         //     title: '"backup-restored".tr()',
  //         //     icon: Icons.settings_backup_restore_rounded,
  //         //   ),
  //         // );
  //         popRoute(context);
  //         // restartAppPopup(
  //         //   context,
  //         //   description: kIsWeb ? "refresh-required-to-load-backup".tr() : "restart-required-to-load-backup".tr(),
  //         //   // codeBlock: file.name.toString() +
  //         //   //     (file.modifiedTime == null
  //         //   //         ? ""
  //         //   //         : ("\n" +
  //         //   //             getWordedDateShort(
  //         //   //               file.modifiedTime!,
  //         //   //               showTodayTomorrow: false,
  //         //   //               includeYear: true,
  //         //   //             ))),
  //         // );
  //       },
  //       onError: (error) {
  //         // openSnackbar(
  //         //   SnackbarMessage(
  //         //     title: error.toString(),
  //         //     icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
  //         //   ),
  //         // );
  //       },
  //     );
  //   } catch (e) {
  //     popRoute(context);
  //     // openSnackbar(
  //     //   SnackbarMessage(
  //     //     title: e.toString(),
  //     //     icon: Icons.error_rounded,
  //     //   ),
  //     // );
  //   }
  // }

  // Future<bool> signInAndSync(BuildContext context, {required dynamic Function() next}) async {
  //   dynamic result = true;
  //   if (appStateSettings["hasSignedIn"] != true) {
  //     result = await openPopup(
  //       null,
  //       icon: Icons.badge_rounded,
  //       title: 'Backups',
  //       description: '"google-drive-backup-disclaimer".tr()',
  //       onSubmitLabel: '"continue".tr()',
  //       onSubmit: () => popRoute(null, true),
  //       onCancel: () => popRoute(null),
  //       onCancelLabel: 'Cancel',
  //     );
  //   }

  //   if (result != true) return false;
  //   try {
  //     await signInGoogle(context: context, waitForCompletion: false, next: next);
  //     if (appStateSettings["username"] == "" && googleUser != null) {
  //       await updateSettings(
  //         "username",
  //         googleUser?.displayName ?? "",
  //         pagesNeedingRefresh: [0],
  //         updateGlobalState: false,
  //       );
  //     }
  //     if (googleUser != null) {
  //       await syncData(context);
  //       await syncPendingQueueOnServer();
  //       await getCloudBudgets();

  //       await createBackupInBackground(context);
  //     } else {
  //       throw ("cannot sync data - user not logged in");
  //     }

  //     return true;
  //   } catch (e) {
  //     debugPrint("Error syncing data after login!");
  //     $logger.e(e);
  //     return false;
  //   }
  // }

  // Future<void> createBackupInBackground(BuildContext context) async {
  //   if (appStateSettings["hasSignedIn"] == false) return;
  //   if (errorSigningInDuringCloud == true) return;
  //   if (kIsWeb && !entireAppLoaded) return;
  //   // print(entireAppLoaded);
  //   print("Last backup: " + appStateSettings["lastBackup"]);
  //   // Only run this once, don't run again if the global state changes (e.g. when changing a setting)
  //   // Update: Does this still run when global state changes? I don't think so...
  //   // If the entire app is loaded and we want to do an auto backup, lets do it no matter what!
  //   // if (entireAppLoaded == false || entireAppLoaded) {
  //   if (appStateSettings["autoBackups"] == true) {
  //     DateTime lastUpdate = DateTime.parse(appStateSettings["lastBackup"]);
  //     DateTime nextPlannedBackup = lastUpdate.add(Duration(days: appStateSettings["autoBackupsFrequency"]));
  //     print("next backup planned on " + nextPlannedBackup.toString());
  //     if (DateTime.now().millisecondsSinceEpoch >= nextPlannedBackup.millisecondsSinceEpoch) {
  //       print("auto backing up");

  //       bool hasSignedIn = false;
  //       if (googleUser == null) {
  //         hasSignedIn = await signInGoogle(context: context, waitForCompletion: false);
  //       } else {
  //         hasSignedIn = true;
  //       }
  //       if (hasSignedIn == false) {
  //         return;
  //       }
  //       await createBackup(context, silentBackup: true, deleteOldBackups: true);
  //     } else {
  //       print("backup already made today");
  //     }
  //   }
  //   // }
  //   return;
  // }

  // Future forceDeleteDB() async {
  //   if (kIsWeb) {
  //     final html.Storage localStorage = html.window.localStorage;
  //     localStorage.clear();
  //   } else {
  //     final dbFolder = await getApplicationDocumentsDirectory();
  //     final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));
  //     await dbFile.delete();
  //   }
  // }

  Future<void> saveFileInDrive({
    required gapis.AccessToken accessToken,
    required File file,
    // bool? silentBackup,
    // bool deleteOldBackups = false,
    // String? clientIDForSync,
  }) async {
    // try {
    //   if (silentBackup == false || silentBackup == null) {
    //     loadingIndeterminateKey.currentState?.setVisibility(true);
    //   }
    //   await backupSettings();
    // } catch (e) {
    //   if (silentBackup == false || silentBackup == null) {
    //     maybePopRoute(context);
    //   }
    //   openSnackbar(SnackbarMessage(title: e.toString(), icon: Icons.error_rounded));
    // }

    try {
      // if (deleteOldBackups) await deleteRecentBackups(context, appStateSettings["backupLimit"], silentDelete: true);

      // final currentDBFileInfo = await getCurrentDBFileInfo();

      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      $logger.i('File Size ${(file.lengthSync() / 1e+6).toString()}');
      final dbFileBytes = await file.readAsBytes();

      final media = drive.Media(file.openRead(), dbFileBytes.length);
      final dateTime = DateTime.now().toUtc();
      final driveFile = drive.File(
        name: 'invesly-${dateTime.millisecondsSinceEpoch}.db',
        modifiedTime: dateTime,
        parents: ['appDataFolder'],
      );

      // if (clientIDForSync != null)
      // driveFile.name = getCurrentDeviceSyncBackupFileName(clientIDForSync: clientIDForSync);

      await driveApi.files.create(driveFile, uploadMedia: media);

      // if (clientIDForSync == null)
      //   // openSnackbar(
      //   //   SnackbarMessage(title: '"backup-created".tr()', description: driveFile.name, icon: Icons.backup_rounded),
      //   // );
      //   if (clientIDForSync == null)
      //     await updateSettings(
      //       "lastBackup",
      //       DateTime.now().toString(),
      //       pagesNeedingRefresh: [],
      //       updateGlobalState: false,
      //     );
    } catch (e) {
      if (e is DetailedApiRequestError && e.status == 401) {
        $logger.e('Unauthorized error while creating backup: $e');
        // await refreshGoogleSignIn();
      } else if (e is PlatformException) {
        $logger.e('Platform error while creating backup: $e');
        // await refreshGoogleSignIn();
      } else {
        $logger.e(e);
        // openSnackbar(
        //   SnackbarMessage(title: e.toString(), icon: Icons.error_rounded),
        // );
      }
    }
  }

  Future<void> deleteFilesFromDrive(gapis.AccessToken accessToken) async {
    try {
      final files = await getDriveFiles(accessToken);

      if (files == null || files.isEmpty) {
        return;
      }

      // files.forEach((file) async {
      //   await deleteBackup(accessToken: accessToken, fileId: file.id!);
      // });
      Future.wait(files.map((file) => deleteFileFromDrive(accessToken: accessToken, fileId: file.id!)));
    } catch (err) {
      $logger.e(err);
      // openSnackbar(
      //   SnackbarMessage(
      //     title: err.toString(),
      //     icon: Icon(Icons.error_rounded),
      //   ),
      // );
    }
  }

  Future<void> deleteFileFromDrive({required gapis.AccessToken accessToken, required String fileId}) async {
    try {
      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      await driveApi.files.delete(fileId);
    } catch (err) {
      $logger.e(err);
      // openSnackbar(SnackbarMessage(title: err.toString()));
    }
  }
}
