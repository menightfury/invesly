import 'dart:io';

import 'package:csv/csv.dart';

import 'package:invesly/common_libs.dart';
import 'package:invesly/database/invesly_api.dart';
import 'package:path/path.dart' as p;

class BackupRepository {
  // singleton api instance
  static BackupRepository? _instance;
  static BackupRepository get instance {
    assert(_instance != null, 'Please make sure to initialize before getting repository');
    return _instance!;
  }

  factory BackupRepository.initialize(InveslyApi api) {
    _instance ??= BackupRepository._(api);
    return _instance!;
  }
  const BackupRepository._(this._api);

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

  // ~ Export related methods
  // Select a directory for exporting database or csv
  Future<String?> selectDirectory() async {
    try {
      // final dir = await _getDownloadsDirectory();
      final path = await FilePicker.platform.getDirectoryPath();
      if (path == null || path.isEmpty) {
        return null;
      }

      return path;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Export database
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

  // Export CSV
  Future<File?> exportCsv(String csvData, String directoryPath) async {
    final file = File(p.join(directoryPath, 'transactions-${DateTime.now().millisecondsSinceEpoch}.csv'));
    try {
      return await file.writeAsString(csvData, flush: true);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  // ~ Import related methods
  // Select a database file for importing
  Future<File?> selectDbFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite3'],
        allowMultiple: false,
      );
      if (result == null) return null;

      return File(result.files.single.path!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Select a CSV file for importing
  Future<File?> selectCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: Platform.isWindows ? FileType.custom : FileType.any,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );
      if (result == null) return null;

      return File(result.files.single.path!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Read file content as bytes
  Future<List<int>> getFileContentAsBytes(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw Exception('The file is invalid or could not be read');
    }
  }

  // Read file content as String
  Future<String> getFileContentAsString(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      throw Exception('The file is invalid or could not be read');
    }
  }

  // (Over) Write database file
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
    } catch (e) {
      throw Exception('Error saving backup to device');
    }
  }

  static List<List<dynamic>> processCsv(String csvData) {
    return const CsvToListConverter().convert(csvData, eol: '\n');
  }
}
