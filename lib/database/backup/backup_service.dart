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

  File get databaseFile => File(_api.dbPath);

  Future<File?> exportDatabase() async {
    // final dir = await _getDownloadsDirectory();
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path == null || path.isEmpty) {
      return null;
    }

    final destFile = File(p.join(path, 'invesly-${DateTime.now().toUtc().millisecondsSinceEpoch}.db'));
    // final dir = await getApplicationDocumentsDirectory();
    // final destination = Directory(p.join(dir.path, fileName));
    // if ((await destination.exists())) {
    //   final status = await Permission.storage.status;
    //   if (!status.isGranted) {
    //     await Permission.storage.request();
    //   }
    // } else {
    //   if (await Permission.storage.request().isGranted) {
    //     // Either the permission was already granted before or the user just granted it.
    //     await destination.create();
    //   } else {
    //     print('Please give permission');
    //   }
    // }

    return await databaseFile.copy(destFile.path);
  }

  Future<List<int>?> getFileContent() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: Platform.isWindows ? FileType.custom : FileType.any,
        allowedExtensions: ['db', 'sqlite3'],
        allowMultiple: false,
      );
    } catch (e) {
      throw Exception(e.toString());
    }

    if (result != null) {
      File selectedFile = File(result.files.single.path!);

      try {
        final currentDBContent = await selectedFile.readAsBytes();
        return currentDBContent;
      } catch (e) {
        throw Exception('The database is invalid or could not be read');
      }
    }
  }

  Future<void> writeDatabase(List<int> fileContent) async {
    try {
      // sqflite - copy from assets (for optimizing performance, asset is copied only once)
      // should happen only first time the application is launched copy from asset
      // final isDbExists = await databaseExists(_api.dbPath);
      // if (!isDbExists) {
      if (fileContent.isEmpty) {
        // final data = await rootBundle.load('assets/data/initial.db');
        // bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        // $logger.i('Data written from assets');
        return;
      }

      // write and flush the bytes written
      await File(_api.dbPath).writeAsBytes(fileContent, flush: true);
      // }
      // else {
      //   $logger.d('Database exists. No need to overwrite.');
      // }
    } catch (e) {
      $logger.e('Error saving backup to device: $e');
      Exception('Error saving backup to device');
    }
  }

  static List<List<dynamic>> processCsv(String csvData) {
    return const CsvToListConverter().convert(csvData, eol: '\n');
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
