import 'dart:async';

import 'package:url_launcher/url_launcher_string.dart';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../metrics/metrics.dart';
import '../use_case.dart';
import 'get_brand.dart';

class LaunchSignUp extends UseCase with Loggable {
  late final _getBrand = GetBrand();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() {
    final brand = _getBrand();

    // Opening this in an external application because it is a multi-stage
    // process that will be inconvenient to use in an in-app WebView.
    unawaited(
      launchUrlString(
        brand.signUpUrl.toString(),
        mode: LaunchMode.externalApplication,
      ),
    );

    _metricsRepository.track('url-sign-up-launched', {'url': brand.signUpUrl});
  }
}
