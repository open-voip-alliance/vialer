import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvRepository {
  late Map<String, String> _env;

  Future<void> load() async {
    await dotenv.load();
    _env = dotenv.env;
  }

  String get(String key) => _env[key] ?? '';

  String get errorTrackingDsn => get('SENTRY_DSN');

  String get logentriesAndroidToken => get('LOGENTRIES_ANDROID_TOKEN');

  String get logentriesIosToken => get('LOGENTRIES_IOS_TOKEN');

  String get segmentAndroidKey => get('SEGMENT_ANDROID_KEY');

  String get segmentIosKey => get('SEGMENT_IOS_KEY');

  String get mergeRequest => get('MERGE_REQUEST');

  String get branch => get('BRANCH');

  String get tag => get('TAG');

  bool get sandbox => get('SANDBOX').toBool();

  bool get inTest => get('IN_TEST').toBool();

  bool get isProduction => get('IS_PRODUCTION').toBool();
}

extension Envrironment on String? {
  bool toBool() => this == '1' || this?.toLowerCase() == 'true';
}
