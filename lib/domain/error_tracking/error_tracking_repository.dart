import 'package:dartx/dartx.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vialer/app/util/loggable.dart';

import '../../dependency_locator.dart';
import '../env.dart';
import '../user/user.dart';

class ErrorTrackingRepository with Loggable {
  Future<void> run(
    void Function() appRunner,
    String dsn,
    User? user,
  ) async {
    await SentryFlutter.init(
      (options) => options
        ..dsn = dsn
        ..beforeSend = (event, {dynamic hint}) {
          logger.logSentryEvent(event);
          return event.copyWith(user: SentryUser(id: user?.uuid));
        },
      appRunner: appRunner,
    );
  }
}

extension on Logger {
  void logSentryEvent(SentryEvent event) => severe(
        // The event id lets you look this up in Sentry so we don't need
        // to display the entire stack trace.
        'Error [${event.sentryUrl}]: ${event.title}',
      );
}

extension on SentryEvent {
  String get title => exceptions?.firstOrNull?.value ?? 'unknown';

  EnvRepository get env => dependencyLocator<EnvRepository>();

  String get baseUrl =>
      // Extracts our sentry URL from the [errorTrackingDsn] env var so we don't
      // need to repeat it.
      RegExp('@([a-z\.]+)\/').firstMatch(env.errorTrackingDsn)?.group(0) ?? '';

  String get sentryUrl {
    final project = env.isProduction ? 'vialer-app' : 'vialer-beta-environment';

    return 'https://${baseUrl}organizations/sentry/discover/$project:$eventId/';
  }
}
