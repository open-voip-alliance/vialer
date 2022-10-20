import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openDatabaseConnection(String filename) {
  return LazyDatabase(() async {
    return NativeDatabase(await getDatabaseFile(filename));
  });
}

LazyDatabase openDatabaseConnectionInIsolate(String path) {
  return LazyDatabase(() async {
    return NativeDatabase(File(path));
  });
}

Future<File> getDatabaseFile(String filename) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return File(p.join(dbFolder.path, filename));
}
