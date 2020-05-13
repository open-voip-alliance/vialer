import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/repositories/env.dart';

class DeviceEnvRepository extends EnvRepository {
  static const _sentryDsnKey = 'SENTRY_DSN';

  static const _logentriesAndroidTokenKey = 'LOGENTRIES_ANDROID_TOKEN';

  static const _logentriesIosTokenKey = 'LOGENTRIES_IOS_TOKEN';

  static const _commitHashKey = 'COMMIT_HASH';

  Map<String, String> __env;

  Future<Map<String, String>> get _env async {
    if (__env == null) {
      await DotEnv().load();
      __env = DotEnv().env;
    }

    return __env;
  }

  Future<String> _get(String key) async => (await _env)[key];

  @override
  Future<String> get sentryDsn => _get(_sentryDsnKey);

  @override
  Future<String> get logentriesAndroidToken => _get(_logentriesAndroidTokenKey);

  @override
  Future<String> get logentriesIosToken => _get(_logentriesIosTokenKey);

  @override
  Future<String> get commitHash => _get(_commitHashKey);
}
