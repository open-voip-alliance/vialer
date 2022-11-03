import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_pending_remote_logs_isolate_request.freezed.dart';

@freezed
class UploadPendingRemoteLogsIsolateRequest
    with _$UploadPendingRemoteLogsIsolateRequest {
  const factory UploadPendingRemoteLogsIsolateRequest({
    required int batchSize,
    required String packageName,
    required String appVersion,
    required String remoteLoggingId,
    required String serviceBaseUrl,
    required String logToken,
    required String databasePath,
  }) = _UploadPendingRemoteLogsIsolateRequest;
}
