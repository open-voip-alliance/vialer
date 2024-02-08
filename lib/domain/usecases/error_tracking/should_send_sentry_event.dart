import 'package:dartx/dartx.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vialer/domain/usecases/use_case.dart';

class ShouldSendSentryEvent extends UseCase {
  /// If the stack trace contains any of these phrases, they will not be sent
  /// to Sentry.
  final ignore = [
    'io_client',
    'IOClient',
    'AvailabilityCloseReason',
  ];

  bool call(SentryEvent event) {
    final exceptions = event.exceptions;

    if (exceptions == null || exceptions.isEmpty) return true;

    final trace = exceptions.flatten();

    return ignore.none((ignoreString) => trace.contains(ignoreString));
  }
}

extension on List<SentryException> {
  String flatten() => map(
        (e) =>
            '${e.value} ${e.stackTrace?.frames.map((e) => e.absPath).join()}',
      ).join();
}
