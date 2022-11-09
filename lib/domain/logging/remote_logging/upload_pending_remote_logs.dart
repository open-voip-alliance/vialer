import 'dart:convert';

import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';

import '../../../app/util/pigeon.dart';
import '../../../app/util/single_task.dart';
import '../../../dependency_locator.dart';
import '../../env.dart';
import '../../use_case.dart';
import '../../user/get_build_info.dart';
import '../../user/get_stored_user.dart';
import '../../user/settings/app_setting.dart';
import '../../user/user.dart';
import '../database/log_events.dart';
import '../logging_repository.dart';
import 'remote_logging_repository.dart';
import 'remote_logging_service.dart';
import 'upload_pending_remote_logs_isolate_request.dart';

class UploadPendingRemoteLogs extends UseCase {
  late final _loggingRepository = dependencyLocator<LoggingRepository>();
  late final _envRepository = dependencyLocator<EnvRepository>();
  late final _getBuildInfo = GetBuildInfoUseCase();
  late final _getUser = GetStoredUserUseCase();
  late final _nativeLogging = NativeLogging();

  /// The number of logs we will read from the database, and submit to the API
  /// in a single request.
  static const _batchSize = 1000;

  Future<void> call() async {
    final user = _getUser();
    final logToken = await _envRepository.logToken;

    if (user == null) return;

    if (!user.hasEnabledRemoteLogging) return;

    if (logToken.isNullOrBlank) {
      throw ArgumentError(
        'Log token is not set while remote logging has been enabled. '
        'Update .env file with LOG_TOKEN=xxxx',
      );
    }

    if (await _loggingRepository.logsAreEmpty) return;

    final buildInfo = await _getBuildInfo();
    final baseUrl = await user.client.voip.middlewareUrl.toString();

    return SingleInstanceTask.of(this).run(() async {
      return Future.wait(
        [
          compute(
            _uploadPendingLogsToRemote,
            UploadPendingRemoteLogsIsolateRequest(
              batchSize: _batchSize,
              packageName: buildInfo.packageName,
              appVersion: buildInfo.version,
              remoteLoggingId: user.loggingIdentifier,
              serviceBaseUrl: baseUrl,
              logToken: logToken,
              databaseIsolateSendPort: LoggingDatabase.portToSendToIsolate,
            ),
          ),
          _nativeLogging.uploadPendingLogs(
            _batchSize,
            buildInfo.packageName,
            buildInfo.version,
            user.loggingIdentifier,
            baseUrl,
            logToken,
          ),
        ],
      );
    });
  }
}

extension on LogEvent {
  int get logTimeAsNanoSeconds => logTime * 1000 * 1000;

  RemoteLoggingMessage toRemoteLoggingMessage({
    required String version,
    required String remoteLoggingId,
  }) =>
      RemoteLoggingMessage(
        time: logTimeAsNanoSeconds.toString(),
        message: jsonEncode({
          'user': remoteLoggingId,
          'logged_from': name,
          'message': message,
          'level': level.name,
          'app_version': version,
        }),
      );
}

/// Uploads the pending logs to the remote server. This is designed to be run
/// in an isolate.
Future<void> _uploadPendingLogsToRemote(
  UploadPendingRemoteLogsIsolateRequest request, {
  RemoteLoggingRepository? remoteLoggingRepository,
  LoggingRepository? localLoggingRepository,
}) async {
  final remoteLogging = remoteLoggingRepository ??
      RemoteLoggingRepository(
        RemoteLoggingService.createInIsolate(request.serviceBaseUrl),
      );

  final logging = localLoggingRepository ??
      LoggingRepository(
        await LoggingDatabase.fromSendPort(request.databaseIsolateSendPort),
      );

  final events = await logging.getOldestLogs(amount: request.batchSize);

  if (events.isEmpty) return;

  final success = await remoteLogging.upload(
    request.packageName,
    request.logToken,
    events
        .map(
          (e) => e.toRemoteLoggingMessage(
            version: request.appVersion,
            remoteLoggingId: request.remoteLoggingId,
          ),
        )
        .toList(),
  );

  if (success) {
    await logging.deleteLogs(events.map((e) => e.id).toList());

    /// We will call this recursively to upload all the logs that we have.
    return await _uploadPendingLogsToRemote(
      request,
      remoteLoggingRepository: remoteLogging,
      localLoggingRepository: logging,
    );
  }
}

extension on User {
  bool get hasEnabledRemoteLogging => settings.get(AppSetting.remoteLogging);
}

extension on LoggingRepository {
  Future<bool> get logsAreEmpty async => !(await hasLogs());
}
