import 'package:url_launcher/url_launcher_string.dart';
import 'package:vialer/data/models/user/brand.dart';
import 'package:vialer/data/repositories/onboarding/country_repository.dart';
import 'package:vialer/presentation/features/onboarding/controllers/mobile_number/country_field/cubit.dart';

import '../../../data/repositories/metrics/metrics.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';
import 'get_brand.dart';

class LaunchSupportPage extends UseCase {
  late final _getBrand = GetBrand();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();
  late final _countryRepository = dependencyLocator<CountryRepository>();

  void call() async {
    final brand = _getBrand();

    if (!brand.hasSupportUrl) {
      throw Exception('${brand.appName} has no support URL configured');
    }

    final countries = await _countryRepository.getCountries();

    final country = await countries.getPreferredCurrentCountry();

    final url = brand.supportUrlForCountry(country.isoCode);

    if (url == null) {
      throw Exception('${brand.appName} has no support URL configured');
    }

    launchUrlString(url.toString());

    _metricsRepository.track('support-page-launched', {'url': url.toString()});
  }
}

extension on Brand {
  Uri? supportUrlForCountry(String isoCode) {
    if (isoCode != 'NL') return supportUrl;

    if (supportUrlNL == null) return supportUrl;

    return supportUrlNL;
  }
}
