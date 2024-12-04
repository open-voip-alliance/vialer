import 'package:url_launcher/url_launcher_string.dart';
import 'package:vialer/data/models/user/brand.dart';

import '../../../data/repositories/metrics/metrics.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'get_brand.dart';

class LaunchSupportPage extends UseCase {
  late final _getBrand = GetBrand();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

  void call() {
    final brand = _getBrand();

    if (!brand.hasSupportUrl) {
      throw Exception('${brand.appName} has no support URL configured');
    }

    launchUrlString(brand.supportUrl.toString());

    _metricsRepository.track('support-page-launched');
  }
}
