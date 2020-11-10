import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvRepository {
  static const _sentryDsnKey = 'SENTRY_DSN';

  static const _logentriesAndroidTokenKey = 'LOGENTRIES_ANDROID_TOKEN';

  static const _logentriesIosTokenKey = 'LOGENTRIES_IOS_TOKEN';

  Map<String, String> __env;

  Future<Map<String, String>> get _env async {
    if (__env == null) {
      await DotEnv().load();
      __env = DotEnv().env;
    }

    return __env;
  }

  Future<String> _get(String key) async => (await _env)[key];

  Future<String> get sentryDsn => _get(_sentryDsnKey);

  Future<String> get logentriesAndroidToken => _get(_logentriesAndroidTokenKey);

  Future<String> get logentriesIosToken => _get(_logentriesIosTokenKey);
}
