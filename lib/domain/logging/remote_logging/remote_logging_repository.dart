import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/util/loggable.dart';
import 'remote_logging_service.dart';

part 'remote_logging_repository.freezed.dart';

class RemoteLoggingRepository with Loggable {
  final RemoteLoggingService _service;

  RemoteLoggingRepository(this._service);

  Future<bool> upload(
    String appId,
    String logToken,
    List<RemoteLoggingMessage> messages,
  ) async {
    messages.validate();

    final response = await _service.log(
      token: logToken,
      appId: appId,
      logs: messages.map((message) => [message.time, message.message]).toList(),
    );

    if (!response.isSuccessful) {
      logFailedResponse(response);
    }

    return response.isSuccessful;
  }
}

extension on List<RemoteLoggingMessage> {
  void validate() {
    if (any((message) => message.isNotInNanoSeconds)) {
      throw ArgumentError('All log timestamps must be in nano seconds');
    }
  }
}

extension on RemoteLoggingMessage {
  bool get isNotInNanoSeconds => time.length < 19;
}

@freezed
class RemoteLoggingMessage with _$RemoteLoggingMessage {
  const factory RemoteLoggingMessage({
    required String time,
    required String message,
  }) = _RemoteLoggingMessage;
}
