import 'package:chopper/chopper.dart';
import 'package:dartx/dartx.dart';
import 'package:logging/logging.dart';

mixin Loggable {
  late final Logger logger = Logger('@$runtimeType');

  /// A general use method to log something useful when a response is failed,
  /// nothing will be logged for a successful response.
  ///
  /// This could be implemented as an HTTP-level interceptor but this could
  /// potentially cause spammy logs, this way there is a direct decision
  /// to log this.
  ///
  /// @param name A name that you wish to give to this response to make
  /// logging clearer.
  void logFailedResponse(Response response, {String? name}) {
    if (response.isSuccessful) return;

    final url = response.base.request?.url.toString() ?? 'UNKNOWN-URL';
    final statusCode = response.statusCode;
    final errorMessage = response.error as String?;

    var message = name != null ? '[$name] request' : 'Request';

    message = '$message to [$url] failed, with status code [$statusCode].';

    if (errorMessage?.isNotNullOrBlank == true) {
      message =
          '$message The response contained an error message [$errorMessage].';
    }

    logger.warning(message);
  }
}
