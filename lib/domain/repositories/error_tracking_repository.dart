import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorTrackingRepository {
  String? userId;

  Future<void> run(void Function() appRunner, String dsn) async {
    await SentryFlutter.init(
      (options) => options
        ..dsn = dsn
        ..beforeSend = (event, {hint}) => event.copyWith(
              user: SentryUser(id: userId),
            ),
      appRunner: appRunner,
    );
  }
}
