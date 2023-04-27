import 'package:url_launcher/url_launcher_string.dart';

import '../use_case.dart';
import 'get_brand.dart';

class LaunchPrivacyPolicy extends UseCase {
  late final _getBrand = GetBrand();

  void call() {
    final brand = _getBrand();

    launchUrlString(brand.privacyPolicyUrl.toString());

    track();
  }
}
