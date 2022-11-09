import '../database_util.dart';
import '../use_case.dart';
import 'database/log_events.dart';

class CreateNativeLoggingDatabase extends UseCase {
  Future<void> call() async {
    final file = await getDatabaseFile(NativeLoggingDatabase.dbFilename);

    if (await file.exists()) return;

    final db = NativeLoggingDatabase();

    // Just a simple query to force Drift to create the table.
    await (db.select(db.nativeLogEvents)..limit(1)).getSingleOrNull();
  }
}
