import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvRepository {
  Map<String, String>? __env;

  Future<Map<String, String>> get _env async {
    if (__env == null) {
      await dotenv.load();
      __env = dotenv.env;
    }

    return __env!;
  }

  Future<String> _get(String key) async => (await _env)[key] ?? '';

  Future<String> get errorTrackingDsn => _get('SENTRY_DSN');

  Future<String> get logentriesAndroidToken => _get('LOGENTRIES_ANDROID_TOKEN');

  Future<String> get logentriesIosToken => _get('LOGENTRIES_IOS_TOKEN');

  Future<String> get mergeRequest => _get('MERGE_REQUEST');

  Future<String> get branch => _get('BRANCH');

  Future<String> get tag => _get('TAG');

  Future<bool> get sandbox async => (await _get('SANDBOX')).toBool();
}

extension on String {
  bool toBool() {
    return this == '1' || toLowerCase() == 'true';
  }
}
