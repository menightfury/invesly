import 'dart:io';

import 'package:csv/csv.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

import 'package:invesly/common_libs.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BackupRestoreRepository {
  static Future<Directory> _getDownloadsDirectory() async {
    final dir = await getDownloadsDirectory();
    if (dir != null) {
      return dir;
    }

    final dir2 = Directory('/storage/emulated/0/Download');
    if (await dir2.exists()) {
      return dir2;
    }

    return await getTemporaryDirectory();
  }
  // AppDB db = AppDB.instance;

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

  Future<List<drive.File>?> getDriveFiles(drive.DriveApi driveApi) async {
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

  Future<List<int>?> getDriveFileContent({required AccessToken accessToken, required String fileId}) async {
    try {
      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      final file = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

      final List<int> dataStore = [];
      file.stream.listen(
        (data) => dataStore.insertAll(dataStore.length, data),
        onError: (err) => $logger.e('Error :$err'),
      );
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

  // bool openDatabaseCorruptedPopup(BuildContext context) {
  //   if (isDatabaseCorrupted) {
  //     openPopup(
  //       context,
  //       icon: appStateSettings["outlinedIcons"] ? Icons.heart_broken_outlined : Icons.heart_broken_rounded,
  //       title: '"database-corrupted".tr()',
  //       description: '"database-corrupted-description".tr()',
  //       descriptionWidget: CodeBlock(text: databaseCorruptedError),
  //       barrierDismissible: false,
  //       onSubmit: () async {
  //         popRoute(context);
  //         await importDB(context, ignoreOverwriteWarning: true);
  //       },
  //       onSubmitLabel: '"import-backup".tr()',
  //       onCancel: () async {
  //         popRoute(context);
  //         await openLoadingPopupTryCatch(() async {
  //           await forceDeleteDB();
  //           await sharedPreferences.clear();
  //         });
  //         restartAppPopup(context);
  //       },
  //       onCancelLabel: '"reset".tr()',
  //     );
  //     // Lock the side navigation
  //     lockAppWaitForRestart = true;
  //     appStateKey.currentState?.refreshAppState();
  //     return true;
  //   }
  //   return false;
  // }

  Future<void> createBackupInGoogleDrive({
    required AccessToken accessToken,
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
      final timestamp = DateFormat("yyyy-MM-dd-hhmmss").format(dateTime);
      final driveFile = drive.File(name: 'invesly-$timestamp.db', modifiedTime: dateTime, parents: ['appDataFolder']);

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

  Future<void> deleteBackups(AccessToken accessToken) async {
    try {
      final files = await getDriveFiles(accessToken);

      if (files == null || files.isEmpty) {
        return;
      }

      // files.forEach((file) async {
      //   await deleteBackup(accessToken: accessToken, fileId: file.id!);
      // });
      Future.wait(files.map((file) => deleteBackup(accessToken: accessToken, fileId: file.id!)));
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

  Future<void> deleteBackup({required AccessToken accessToken, required String fileId}) async {
    try {
      final driveApi = _driveApi ?? await getDriveApi(accessToken);
      await driveApi.files.delete(fileId);
    } catch (err) {
      $logger.e(err);
      // openSnackbar(SnackbarMessage(title: err.toString()));
    }
  }

  // bool openBackupReminderPopupCheck(BuildContext context) {
  //   if ((appStateSettings["currentUserEmail"] == null || appStateSettings["currentUserEmail"] == "") &&
  //       ((appStateSettings["numLogins"] + 1) % 7 == 0) &&
  //       appStateSettings["canShowBackupReminderPopup"] == true) {
  //     openPopup(
  //       context,
  //       icon: MoreIcons.google_drive,
  //       iconScale: 0.9,
  //       title: "backup-your-data-reminder".tr(),
  //       description: "backup-your-data-reminder-description".tr() + " " + "google-drive".tr(),
  //       onSubmitLabel: "backup".tr().capitalizeFirst,
  //       onSubmit: () async {
  //         popRoute(context);
  //         await signInAndSync(context, next: () {});
  //       },
  //       onCancelLabel: "never".tr().capitalizeFirst,
  //       onCancel: () async {
  //         popRoute(context);
  //         await updateSettings("canShowBackupReminderPopup", false, updateGlobalState: false);
  //       },
  //       onExtraLabel: 'Later',
  //       onExtra: () {
  //         popRoute(context);
  //       },
  //     );
  //     return true;
  //   }
  //   return false;
  // }

  Future<void> writeDatabaseFile([List<int>? fileContent]) async {
    try {
      // sqflite - copy from assets (for optimizing performance, asset is copied only once)
      // should happen only first time the application is launched copy from asset
      final isDbExists = await databaseExists(_api.dbPath);
      if (!isDbExists) {
        List<int>? bytes = fileContent;

        if (bytes == null || bytes.isEmpty) {
          // final data = await rootBundle.load('assets/data/initial.db');
          // bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          // $logger.i('Data written from assets');
          return;
        }

        // write and flush the bytes written
        await File(_api.dbPath).writeAsBytes(bytes, flush: true);
      } else {
        $logger.d('Database exists. No need to overwrite.');
      }
    } catch (e) {
      $logger.e('Error saving backup to device: $e');
      throw ('Error saving backup to device');
    }
  }

  // Future<void> downloadDatabaseFile() async {
  //   List<int> dbFileInBytes = await File(await db.databasePath).readAsBytes();

  //   String downloadPath = await getDownloadPath();
  //   downloadPath = path.join(downloadPath, "invesly-${DateFormat('yyyyMMdd-Hms').format(DateTime.now())}.db");

  //   File downloadFile = File(downloadPath);

  //   await downloadFile.writeAsBytes(dbFileInBytes);
  // }

  // Future<bool> importDatabase() async {
  //   FilePickerResult? result;

  //   try {
  //     result = await FilePicker.platform.pickFiles(
  //       type: Platform.isWindows ? FileType.custom : FileType.any,
  //       allowedExtensions: Platform.isWindows ? ['db'] : null,
  //       allowMultiple: false,
  //     );
  //   } catch (e) {
  //     throw Exception(e.toString());
  //   }

  //   if (result != null) {
  //     File selectedFile = File(result.files.single.path!);

  //     // Delete the previous database
  //     String dbPath = await db.databasePath;

  //     final currentDBContent = await File(dbPath).readAsBytes();

  //     // Load the new database
  //     await File(dbPath).writeAsBytes(await selectedFile.readAsBytes(), mode: FileMode.write);

  //     try {
  //       final dbVersion = int.parse((await AppDataService.instance.getAppDataItem(AppDataKey.dbVersion).first)!);

  //       if (dbVersion < db.schemaVersion) {
  //         await db.migrateDB(dbVersion, db.schemaVersion);
  //       }

  //       db.markTablesUpdated(db.allTables);
  //     } catch (e) {
  //       // Reset the DB as it was
  //       await File(dbPath).writeAsBytes(currentDBContent, mode: FileMode.write);
  //       db.markTablesUpdated(db.allTables);

  //       debugPrint('Error\n: $e');

  //       throw Exception('The database is invalid or could not be read');
  //     }

  //     return true;
  //   }

  //   return false;
  // }

  static List<List<dynamic>> processCsv(String csvData) {
    return const CsvToListConverter().convert(csvData, eol: '\n');
  }

  static Future<File?> exportDatabaseFile() async {
    // final source = File(InveslyApi.instance.db.path);
    // final fileName = 'invesly-${DateTime.now().millisecondsSinceEpoch}.db';

    // final dir = await getApplicationDocumentsDirectory();
    // final destination = Directory(p.join(dir.path, fileName));
    // // if ((await destination.exists())) {
    // //   final status = await Permission.storage.status;
    // //   if (!status.isGranted) {
    // //     await Permission.storage.request();
    // //   }
    // // } else {
    // //   if (await Permission.storage.request().isGranted) {
    // //     // Either the permission was already granted before or the user just granted it.
    // //     await destination.create();
    // //   } else {
    // //     print('Please give permission');
    // //   }
    // // }

    // return await source.copy(destination.path);
    return null;
  }

  static Future<File?> exportCsv(String csvData) async {
    // final dir = await _getDownloadsDirectory();
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path == null || path.isEmpty) {
      return null;
    }
    final fileName = 'transactions-${DateTime.now().millisecondsSinceEpoch}.csv';
    // final file = File(p.join(dir.path, fileName));
    final file = File(p.join(path, fileName));

    try {
      return await file.writeAsString(csvData, flush: true);
    } catch (err) {
      $logger.e(err);
      return null;
    }
  }
}
