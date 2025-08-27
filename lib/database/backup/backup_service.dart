import 'dart:io';

import 'package:csv/csv.dart';

import 'package:invesly/common_libs.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class BackupDatabaseService {
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
