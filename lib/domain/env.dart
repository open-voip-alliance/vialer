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

  Future<String> get(String key) async => (await _env)[key] ?? '';

  Future<String> get errorTrackingDsn => get('SENTRY_DSN');

  Future<String> get logentriesAndroidToken => get('LOGENTRIES_ANDROID_TOKEN');

  Future<String> get logentriesIosToken => get('LOGENTRIES_IOS_TOKEN');

  Future<String> get logToken => get('LOG_TOKEN');

  Future<String> get segmentAndroidKey => get('SEGMENT_ANDROID_KEY');

  Future<String> get segmentIosKey => get('SEGMENT_IOS_KEY');

  Future<String> get mergeRequest => get('MERGE_REQUEST');

  Future<String> get branch => get('BRANCH');

  Future<String> get tag => get('TAG');

  Future<bool> get sandbox async => (await get('SANDBOX')).toBool();

  Future<bool> get inTest async => (await get('IN_TEST')).toBool();
}

extension on String {
  bool toBool() {
    return this == '1' || toLowerCase() == 'true';
  }
}
