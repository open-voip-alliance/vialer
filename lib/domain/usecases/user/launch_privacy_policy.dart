import 'dart:async';

import 'package:url_launcher/url_launcher_string.dart';

import '../../../data/repositories/metrics/metrics.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'get_brand.dart';

class LaunchPrivacyPolicy extends UseCase {
  late final _getBrand = GetBrand();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() {
    final brand = _getBrand();

    unawaited(launchUrlString(brand.privacyPolicyUrl.toString()));

    _metricsRepository.track('url-privacy-policy-launched');
  }
}
