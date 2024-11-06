import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:vialer/presentation/util/loggable.dart';

import '../../../dependency_locator.dart';
import '../../../domain/usecases/error_tracking/should_send_sentry_event.dart';
import '../../models/user/user.dart';
import '../env.dart';

@singleton
class ErrorTrackingRepository with Loggable {
  final _shouldSend = ShouldSendSentryEvent();

  FutureOr<SentryEvent?> _beforeSend(
    SentryEvent event,
    User? user, {
    dynamic hint,
  }) async {
    final shouldSend = _shouldSend(event);

    logger.logSentryEvent(event, willBeSentToSentry: shouldSend);

    return shouldSend ? event.copyWith(user: SentryUser(id: user?.uuid)) : null;
  }

  Future<void> run(
    void Function() appRunner,
    String dsn,
    User? user,
  ) async {
    await SentryFlutter.init(
      (options) => options
        ..dsn = dsn
        ..sampleRate = 0.5
        ..beforeSend = (event, hint) => _beforeSend(event, user, hint: hint),
      appRunner: appRunner,
    );
  }
}

extension on Logger {
  void logSentryEvent(
    SentryEvent event, {
    bool willBeSentToSentry = true,
  }) =>
      severe(
        // The event id lets you look this up in Sentry so we don't need
        // to display the entire stack trace.
        willBeSentToSentry
            ? 'Error [${event._sentryUrl}]: ${event.title}'
            : 'Error not submitted to Sentry: ${event.title}',
      );
}

extension on SentryEvent {
  String get title => exceptions?.firstOrNull?.value ?? 'unknown';

  EnvRepository get _env => dependencyLocator<EnvRepository>();

  String get _baseUrl =>
      // Extracts our sentry URL from the [errorTrackingDsn] env var so we don't
      // need to repeat it.
      RegExp('@([a-z\.]+)\/').firstMatch(_env.errorTrackingDsn)?.group(1) ?? '';

  String get _sentryUrl {
    final project =
        _env.isProduction ? 'vialer-app' : 'vialer-beta-environment';

    return 'https://${_baseUrl}/organizations/sentry/discover/$project:$eventId/';
  }
}
