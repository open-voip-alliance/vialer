import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:recase/recase.dart';

import '../../dependency_locator.dart';
import '../models/feature/feature.dart';

@singleton
class EnvRepository {
  late Map<String, String> _env;

  @factoryMethod
  static Future<EnvRepository> create() async {
    final env = EnvRepository();
    await env.load();
    return env;
  }

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

  bool get iosSandboxPushNotifications =>
      get('ENABLE_IOS_SANDBOX_PUSH_NOTIFICATIONS').toBool();

  bool get inTest => get('IN_TEST').toBool();

  bool get isProduction => get('IS_PRODUCTION').toBool();

  bool isFeatureFlagEnabled(Feature feature) =>
      get('FEATURE_${feature.name.constantCase}').toBool();
}

extension on String? {
  /// These values are considered "truthy" in the environment file, meaning
  /// they will resolve to [true] when an environment variable is cast
  /// to a boolean.
  ///
  /// These will all be downcased before comparing so case is irrelevant.
  static const truthy = ['1', 'true'];

  bool toBool() => truthy.any(
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
