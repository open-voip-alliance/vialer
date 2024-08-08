import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../../presentation/util/loggable.dart';
import '../../use_case.dart';
import 'package:path/path.dart' as p;

class RemoveLegacyClientCallRecordsFile extends UseCase with Loggable {
  /// We used to store client call records in a sqlite file, this is no longer
  /// the case and we should make sure this file has been completely deleted.
  ///
  /// This can be removed in a future release (2025).
  Future<void> call() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    if (!file.existsSync()) return;
    await file.delete();
  }
}
