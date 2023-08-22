import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dependency_locator.dart';

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

extension Environment on String? {
  /// These values are considered "truthy" in the environment file, meaning
  /// they will resolve to [true] when an environment variable is cast
  /// to a boolean.
  ///
  /// These will all be downcast before comparing so case is irrelevant.
  static const _truthy = ['1', 'true'];

  bool toBool() => _truthy.any(
        (truthy) => truthy.toLowerCase() == this?.toLowerCase(),
      );
}

/// Determine if the app is in production, this means that it is a build
/// that has been (or will be) published for anybody to download
/// from the Play Store/App Store.
///
/// A build that is used for any sort of testing (e.g. internal previews) are
/// not counted as in production.
bool get isProduction => dependencyLocator<EnvRepository>().isProduction;
