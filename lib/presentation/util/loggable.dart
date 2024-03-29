import 'package:chopper/chopper.dart';
import 'package:dartx/dartx.dart';
import 'package:logging/logging.dart';

mixin Loggable {
  late final Logger logger = _create(this);

  /// A general use method to log something useful when a response is failed,
  /// nothing will be logged for a successful response.
  ///
  /// This could be implemented as an HTTP-level interceptor but this could
  /// potentially cause spammy logs, this way there is a direct decision
  /// to log this.
  ///
  /// You can provide a [name] that you wish to give to this response to make
  /// logging clearer.
  void logFailedResponse(Response<dynamic> response, {String? name}) {
    if (response.isSuccessful) return;

    final url = response.base.request?.url.toString() ?? 'UNKNOWN-URL';
    final statusCode = response.statusCode;
    final errorMessage = response.error as String?;

    var message = name != null ? '[$name] request' : 'Request';

    message = '$message to [$url] failed, with status code [$statusCode].';

    if (errorMessage.isNotNullOrBlank) {
      message =
          '$message The response contained an error message [$errorMessage].';
    }

    logger.warning(message);
  }
}

extension GetLogger on Object {
  /// This should only be used if the [Loggable] mixin is not available, such
  /// as in an extension or in class that needs a const constructor.
  Logger get logger => _create(this);
}

Logger _create(Object object) => Logger('@${object.runtimeType}');
