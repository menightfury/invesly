import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/abusiveexperiencereport/v1.dart';
import 'package:intl/intl.dart';
import 'package:invesly/common/presentations/widgets/popups.dart';
import 'package:invesly/common_libs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:googleapis/drive/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();
  GoogleAuthClient(this._headers);
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  GoogleSignIn? googleSignIn;
  GoogleSignInAccount? googleUser;

  final scopes = <String>[
    // See https://github.com/flutter/flutter/issues/155490 and https://github.com/flutter/flutter/issues/155429
    // Once an account is logged in with these scopes, they are not needed
    // So we will keep these to apply for all users to prevent errors, especially on silent sign in
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
    DriveApi.driveAppdataScope,
    DriveApi.driveFileScope,
  ];

  Future<void> signInGoogle({
    BuildContext? context,
    bool? waitForCompletion = false,
    bool? silentSignIn,
    Function()? next,
  }) async {
    // bool isConnected = false;
    // if (await checkLockedFeatureIfInDemoMode(context) == false) return false;
    // if (appStateSettings["emailScanning"] == false) gMailPermissions = false;

    try {
      // if (googleUser != null) {
      //   await signOutGoogle();
      //   googleSignIn = null;
      //   settingsPageStateKey.currentState?.refreshState();
      // } else if (googleUser == null) {
      //   googleSignIn = null;
      //   settingsPageStateKey.currentState?.refreshState();
      // }
      //Check connection
      // isConnected = await checkConnection().timeout(Duration(milliseconds: 2500),
      //     onTimeout: () {
      //   throw ("There was an error checking your connection");
      // });
      // if (isConnected == false) {
      //   if (context != null) {
      //     openSnackbar(context, "Could not connect to network",
      //         backgroundColor: lightenPastel(Theme.of(context).colorScheme.error,
      //             amount: 0.6));
      //   }
      //   return false;
      // }

      // if (waitForCompletion == true && context != null) openLoadingPopup(context);
      // if (googleUser == null) {
      googleUser = await GoogleSignIn.instance.authenticate();

      // googleSignIn?.initialize(
      //   clientId: '791480731407-5k0kglrd6k78s11v4bkhnv473tva5862.apps.googleusercontent.com',
      // ); // TODO: Hide client Id
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
      //   // await updateSettings("hasSignedIn", false, updateGlobalState: false);
      // }
      // refreshUIAfterLoginChange();
      throw ('Error signing in');
    }
  }

  // void refreshUIAfterLoginChange() {
  //   sidebarStateKey.currentState?.refreshState();
  //   accountsPageStateKey.currentState?.refreshState();
  //   settingsGoogleAccountLoginButtonKey.currentState?.refreshState();
  // }

  Future<void> signOutGoogle() async {
    // Call disconnect rather than signOut to more fully reset the example app.
    await googleSignIn?.disconnect();
    googleUser = null;
    // await updateSettings("currentUserEmail", "", updateGlobalState: false);
    // await updateSettings("hasSignedIn", false, updateGlobalState: false);
    // refreshUIAfterLoginChange();
  }

  Future<void> refreshGoogleSignIn() async {
    await signOutGoogle();
    await signInGoogle(silentSignIn: kIsWeb ? false : true);
  }

  Future<bool> signInAndSync(BuildContext context, {required dynamic Function() next}) async {
    dynamic result = true;
    if (appStateSettings["hasSignedIn"] != true) {
      result = await openPopup(
        null,
        icon: Icons.badge_rounded,
        title: 'Backups',
        description: '"google-drive-backup-disclaimer".tr()',
        onSubmitLabel: '"continue".tr()',
        onSubmit: () {
          popRoute(null, true);
        },
        onCancel: () {
          popRoute(null);
        },
        onCancelLabel: '"cancel".tr()',
      );
    }

    if (result != true) return false;
    try {
      await signInGoogle(context: context, waitForCompletion: false, next: next);
      if (appStateSettings["username"] == "" && googleUser != null) {
        await updateSettings(
          "username",
          googleUser?.displayName ?? "",
          pagesNeedingRefresh: [0],
          updateGlobalState: false,
        );
      }
      if (googleUser != null) {
        await syncData(context);
        await syncPendingQueueOnServer();
        await getCloudBudgets();

        await createBackupInBackground(context);
      } else {
        throw ("cannot sync data - user not logged in");
      }

      return true;
    } catch (e) {
      debugPrint("Error syncing data after login!");
      $logger.e(e);
      return false;
    }
  }

  Future<void> createBackupInBackground(BuildContext context) async {
    if (appStateSettings["hasSignedIn"] == false) return;
    if (errorSigningInDuringCloud == true) return;
    if (kIsWeb && !entireAppLoaded) return;
    // print(entireAppLoaded);
    print("Last backup: " + appStateSettings["lastBackup"]);
    //Only run this once, don't run again if the global state changes (e.g. when changing a setting)
    // Update: Does this still run when global state changes? I don't think so...
    // If the entire app is loaded and we want to do an auto backup, lets do it no matter what!
    // if (entireAppLoaded == false || entireAppLoaded) {
    if (appStateSettings["autoBackups"] == true) {
      DateTime lastUpdate = DateTime.parse(appStateSettings["lastBackup"]);
      DateTime nextPlannedBackup = lastUpdate.add(Duration(days: appStateSettings["autoBackupsFrequency"]));
      print("next backup planned on " + nextPlannedBackup.toString());
      if (DateTime.now().millisecondsSinceEpoch >= nextPlannedBackup.millisecondsSinceEpoch) {
        print("auto backing up");

        bool hasSignedIn = false;
        if (googleUser == null) {
          hasSignedIn = await signInGoogle(context: context, waitForCompletion: false, silentSignIn: true);
        } else {
          hasSignedIn = true;
        }
        if (hasSignedIn == false) {
          return;
        }
        await createBackup(context, silentBackup: true, deleteOldBackups: true);
      } else {
        print("backup already made today");
      }
    }
    // }
    return;
  }

  Future forceDeleteDB() async {
    if (kIsWeb) {
      final html.Storage localStorage = html.window.localStorage;
      localStorage.clear();
    } else {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));
      await dbFile.delete();
    }
  }

  bool openDatabaseCorruptedPopup(BuildContext context) {
    if (isDatabaseCorrupted) {
      openPopup(
        context,
        icon: appStateSettings["outlinedIcons"] ? Icons.heart_broken_outlined : Icons.heart_broken_rounded,
        title: '"database-corrupted".tr()',
        description: '"database-corrupted-description".tr()',
        descriptionWidget: CodeBlock(text: databaseCorruptedError),
        barrierDismissible: false,
        onSubmit: () async {
          popRoute(context);
          await importDB(context, ignoreOverwriteWarning: true);
        },
        onSubmitLabel: '"import-backup".tr()',
        onCancel: () async {
          popRoute(context);
          await openLoadingPopupTryCatch(() async {
            await forceDeleteDB();
            await sharedPreferences.clear();
          });
          restartAppPopup(context);
        },
        onCancelLabel: '"reset".tr()',
      );
      // Lock the side navigation
      lockAppWaitForRestart = true;
      appStateKey.currentState?.refreshAppState();
      return true;
    }
    return false;
  }

  Future<void> createBackup(
    context, {
    bool? silentBackup,
    bool deleteOldBackups = false,
    String? clientIDForSync,
  }) async {
    try {
      if (silentBackup == false || silentBackup == null) {
        loadingIndeterminateKey.currentState?.setVisibility(true);
      }
      await backupSettings();
    } catch (e) {
      if (silentBackup == false || silentBackup == null) {
        maybePopRoute(context);
      }
      openSnackbar(
        SnackbarMessage(
          title: e.toString(),
          icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
        ),
      );
    }

    try {
      if (deleteOldBackups) await deleteRecentBackups(context, appStateSettings["backupLimit"], silentDelete: true);

      DBFileInfo currentDBFileInfo = await getCurrentDBFileInfo();

      final authHeaders = await googleUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = DriveApi(authenticateClient);

      var media = Media(currentDBFileInfo.mediaStream, currentDBFileInfo.dbFileBytes.length);

      var driveFile = new File();
      final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(DateTime.now().toUtc());
      // -$timestamp
      driveFile.name = "db-v$schemaVersionGlobal-${getCurrentDeviceName()}.sqlite";
      if (clientIDForSync != null)
        driveFile.name = getCurrentDeviceSyncBackupFileName(clientIDForSync: clientIDForSync);
      driveFile.modifiedTime = DateTime.now().toUtc();
      driveFile.parents = ["appDataFolder"];

      await driveApi.files.create(driveFile, uploadMedia: media);

      if (clientIDForSync == null)
        // openSnackbar(
        //   SnackbarMessage(
        //     title: '"backup-created".tr()',
        //     description: driveFile.name,
        //     icon: appStateSettings["outlinedIcons"] ? Icons.backup_outlined : Icons.backup_rounded,
        //   ),
        // );
        if (clientIDForSync == null)
          await updateSettings(
            "lastBackup",
            DateTime.now().toString(),
            pagesNeedingRefresh: [],
            updateGlobalState: false,
          );
    } catch (e) {
      if (e is DetailedApiRequestError && e.status == 401) {
        await refreshGoogleSignIn();
      } else if (e is PlatformException) {
        await refreshGoogleSignIn();
      } else {
        // openSnackbar(
        //   SnackbarMessage(
        //     title: e.toString(),
        //     icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
        //   ),
        // );
      }
    }
  }

  Future<void> deleteRecentBackups(context, amountToKeep, {bool? silentDelete}) async {
    try {
      final authHeaders = await googleUser!.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = DriveApi(authenticateClient);

      FileList fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        $fields: 'files(id, name, modifiedTime, size)',
      );
      List<File>? files = fileList.files;
      if (files == null) {
        throw "No backups found.";
      }

      int index = 0;
      files.forEach((file) {
        // subtract 1 because we just made a backup
        if (index >= amountToKeep - 1) {
          // only delete excess backups that don't belong to a client sync
          if (!isSyncBackupFile(file.name)) deleteBackup(driveApi, file.id ?? "");
        }
        if (!isSyncBackupFile(file.name)) index++;
      });
    } catch (e) {
      // openSnackbar(
      //   SnackbarMessage(
      //     title: e.toString(),
      //     icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
      //   ),
      // );
    }
  }

  Future<void> deleteBackup(DriveApi driveApi, String fileId) async {
    try {
      await driveApi.files.delete(fileId);
    } catch (e) {
      openSnackbar(SnackbarMessage(title: e.toString()));
    }
  }

  Future<void> chooseBackup(
    context, {
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
      openSnackbar(
        SnackbarMessage(
          title: e.toString(),
          icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
        ),
      );
    }
  }

  Future<void> loadBackup(BuildContext context, DriveApi driveApi, File file) async {
    try {
      openLoadingPopup(context);

      await cancelAndPreventSyncOperation();

      List<int> dataStore = [];
      dynamic response = await driveApi.files.get(file.id ?? "", downloadOptions: drive.DownloadOptions.fullMedia);
      response.stream.listen(
        (data) {
          // print("Data: ${data.length}");
          dataStore.insertAll(dataStore.length, data);
        },
        onDone: () async {
          await overwriteDefaultDB(Uint8List.fromList(dataStore));

          // if this is added, it doesn't restore the database properly on web
          // await database.close();
          popRoute(context);
          await resetLanguageToSystem(context);
          await updateSettings("databaseJustImported", true, pagesNeedingRefresh: [], updateGlobalState: false);
          // openSnackbar(
          //   SnackbarMessage(
          //     title: '"backup-restored".tr()',
          //     icon:
          //         appStateSettings["outlinedIcons"]
          //             ? Icons.settings_backup_restore_outlined
          //             : Icons.settings_backup_restore_rounded,
          //   ),
          // );
          popRoute(context);
          // restartAppPopup(
          //   context,
          //   description: kIsWeb ? "refresh-required-to-load-backup".tr() : "restart-required-to-load-backup".tr(),
          //   // codeBlock: file.name.toString() +
          //   //     (file.modifiedTime == null
          //   //         ? ""
          //   //         : ("\n" +
          //   //             getWordedDateShort(
          //   //               file.modifiedTime!,
          //   //               showTodayTomorrow: false,
          //   //               includeYear: true,
          //   //             ))),
          // );
        },
        onError: (error) {
          // openSnackbar(
          //   SnackbarMessage(
          //     title: error.toString(),
          //     icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
          //   ),
          // );
        },
      );
    } catch (e) {
      popRoute(context);
      // openSnackbar(
      //   SnackbarMessage(
      //     title: e.toString(),
      //     icon: Icons.error_rounded,
      //   ),
      // );
    }
  }
}

Future<(DriveApi? driveApi, List<File>?)> getDriveFiles() async {
  try {
    final authHeaders = await googleUser!.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    drive.DriveApi driveApi = drive.DriveApi(authenticateClient);

    drive.FileList fileList = await driveApi.files.list(
      spaces: 'appDataFolder',
      $fields: 'files(id, name, modifiedTime, size)',
    );
    return (driveApi, fileList.files);
  } catch (e) {
    if (e is DetailedApiRequestError && e.status == 401) {
      await refreshGoogleSignIn();
      return await getDriveFiles();
    } else if (e is PlatformException) {
      await refreshGoogleSignIn();
      return await getDriveFiles();
    } else {
      openSnackbar(
        SnackbarMessage(
          title: e.toString(),
          icon: appStateSettings["outlinedIcons"] ? Icons.error_outlined : Icons.error_rounded,
        ),
      );
    }
  }
  return (null, null);
}

double convertBytesToMB(String bytesString) {
  try {
    int bytes = int.parse(bytesString);
    double megabytes = bytes / (1024 * 1024);
    return megabytes;
  } catch (e) {
    debugPrint('Error parsing bytes string: $e');
    return 0.0; // or throw an exception, depending on your requirements
  }
}

Future<bool> saveDriveFileToDevice({
  required BuildContext boxContext,
  required drive.DriveApi driveApi,
  required drive.File fileToSave,
}) async {
  List<int> dataStore = [];
  dynamic response = await driveApi.files.get(fileToSave.id!, downloadOptions: drive.DownloadOptions.fullMedia);
  await for (var data in response.stream) {
    dataStore.insertAll(dataStore.length, data);
  }
  String fileName =
      "cashew-" +
      ((fileToSave.name ?? "") + cleanFileNameString((fileToSave.modifiedTime ?? DateTime.now()).toString()))
          .replaceAll(".sqlite", "") +
      ".sql";

  return await saveFile(
    boxContext: boxContext,
    dataStore: dataStore,
    dataString: null,
    fileName: fileName,
    successMessage: "backup-downloaded-success".tr(),
    errorMessage: "error-downloading".tr(),
  );
}

bool openBackupReminderPopupCheck(BuildContext context) {
  if ((appStateSettings["currentUserEmail"] == null || appStateSettings["currentUserEmail"] == "") &&
      ((appStateSettings["numLogins"] + 1) % 7 == 0) &&
      appStateSettings["canShowBackupReminderPopup"] == true) {
    openPopup(
      context,
      icon: MoreIcons.google_drive,
      iconScale: 0.9,
      title: "backup-your-data-reminder".tr(),
      description: "backup-your-data-reminder-description".tr() + " " + "google-drive".tr(),
      onSubmitLabel: "backup".tr().capitalizeFirst,
      onSubmit: () async {
        popRoute(context);
        await signInAndSync(context, next: () {});
      },
      onCancelLabel: "never".tr().capitalizeFirst,
      onCancel: () async {
        popRoute(context);
        await updateSettings("canShowBackupReminderPopup", false, updateGlobalState: false);
      },
      onExtraLabel: "later".tr().capitalizeFirst,
      onExtra: () {
        popRoute(context);
      },
    );
    return true;
  }
  return false;
}
