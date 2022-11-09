import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:drift/isolate.dart';
import 'package:drift/native.dart';

import '../../../dependency_locator.dart';
import '../../database_util.dart';

part 'log_events.g.dart';

/// This database routes all queries via a [DriftIsolate] which is why there
/// are no typical methods to creating the database. This is required to
/// prevent database locking when accessing from background isolates while
/// the database is constantly being written to.
@DriftDatabase(tables: [LogEvents])
class LoggingDatabase extends _$LoggingDatabase {
  static String get dbFilename => 'logging_db.sqlite';

  LoggingDatabase.connect(DatabaseConnection connection)
      : super.connect(connection);

  /// Called when accessing this database from a background isolate,
  /// the [DriftIsolate.connectPort] should be sent as part of the data
  /// passed to the isolate.
  static Future<LoggingDatabase> fromSendPort(SendPort port) async {
    final isolate = DriftIsolate.fromConnectPort(port);
    return LoggingDatabase.connect(await isolate.connect());
  }

  /// Access the [DriftIsolate.connectPort] this is what should be included
  /// in the request object that is submitted when booting an isolate.
  ///
  /// View [UploadPendingRemoteLogsIsolateRequest] as an example.
  static SendPort get portToSendToIsolate =>
      dependencyLocator<DriftIsolate>().connectPort;

  /// Boots the [DriftIsolate] that is used to handle all database queries,
  /// this should only ever be called once when the application is booted.
  /// Calling this multiple times will caused multiple isolates to be created.
  static Future<DriftIsolate> createIsolate() async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _startBackground,
      _IsolateStartRequest(
        receivePort.sendPort,
        (await getDatabaseFile(dbFilename)).path,
      ),
    );

    return await receivePort.first as DriftIsolate;
  }

  @override
  int get schemaVersion => 1;
}

class LogEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get logTime => integer()();
  IntColumn get level => intEnum<LogLevel>()();
  TextColumn get name => text()();
  TextColumn get message => text()();
}

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// This is a (very slightly) modified method based on the example given in the
/// Drift documentation.
///
/// [Initialization on the main thread](https://drift.simonbinder.eu/docs/advanced-features/isolates/#initialization-on-the-main-thread)
void _startBackground(_IsolateStartRequest request) =>
    request.sendDriftIsolate.send(
      DriftIsolate.inCurrent(
        () => DatabaseConnection.fromExecutor(
          NativeDatabase(File(request.targetPath)),
        ),
      ),
    );

class _IsolateStartRequest {
  final SendPort sendDriftIsolate;
  final String targetPath;

  _IsolateStartRequest(this.sendDriftIsolate, this.targetPath);
}

/// This is used to log from native, it is being created here to keep
/// consistency between the schemas. It should not be used in Dart.
@DriftDatabase(tables: [NativeLogEvents])
class NativeLoggingDatabase extends _$NativeLoggingDatabase {
  static String get dbFilename => 'logging_native_db.sqlite';

  NativeLoggingDatabase() : super(openDatabaseConnection(dbFilename));

  @override
  int get schemaVersion => 1;
}

class NativeLogEvents extends LogEvents {
  @override
  String get tableName => 'log_events';
}
