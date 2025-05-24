import 'dart:io';

import 'package:invesly/common_libs.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ElevatedButton(
            //   onPressed: () async {
            //     final dbFolder = await getDatabasesPath();
            //     File source1 = File('$dbFolder/doggie_database.db');

            //     Directory copyTo = Directory("storage/emulated/0/Sqlite Backup");
            //     if ((await copyTo.exists())) {
            //       // print("Path exist");
            //       final status = await Permission.storage.status;
            //       if (!status.isGranted) {
            //         await Permission.storage.request();
            //       }
            //     } else {
            //       print("not exist");
            //       if (await Permission.storage.request().isGranted) {
            //         // Either the permission was already granted before or the user just granted it.
            //         await copyTo.create();
            //       } else {
            //         print('Please give permission');
            //       }
            //     }

            //     String newPath = "${copyTo.path}/doggie_database.db";
            //     await source1.copy(newPath);
            //   },
            //   child: const Text('Copy DB'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     var databasesPath = await getDatabasesPath();
            //     var dbPath = join(databasesPath, 'doggie_database.db');
            //     await deleteDatabase(dbPath);
            //   },
            //   child: const Text('Delete DB'),
            // ),
            ElevatedButton(
              onPressed: () async {
                // var databasesPath = await getDatabasesPath();
                // var dbPath = join(databasesPath, 'doggie_database.db');

                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  final path = result.files.first.path!;
                  final file = File(path);
                  $logger.f(file.parent.path);
                  // await file.copy('${file.parent.path}/anotherreadme.txt');
                  if (!context.mounted) return;
                  // context.read<AppCubit>().bootstrap(file);
                } else {
                  // User canceled the picker
                }
              },
              child: const Text('Restore DB'),
            ),
          ],
        ),
      ),
    );
  }
}
