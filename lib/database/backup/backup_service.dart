import 'dart:io';

import 'package:csv/csv.dart';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupRestoreRepository {
  BackupRestoreRepository(InveslyApi api) : _api = api;

  final InveslyApi _api;

  // static Future<Directory> _getDownloadsDirectory() async {
  //   final dir = await getDownloadsDirectory();
  //   if (dir != null) {
  //     return dir;
  //   }

  //   final dir2 = Directory('/storage/emulated/0/Download');
  //   if (await dir2.exists()) {
  //     return dir2;
  //   }

  //   return await getTemporaryDirectory();
  // }
  // AppDB db = AppDB.instance;

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
