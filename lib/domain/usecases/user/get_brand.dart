import 'package:dartx/dartx.dart';

import '../../../data/models/user/brand.dart';
import '../use_case.dart';

class GetBrand extends UseCase {
  Brand call() {
    const signUpUrl = String.fromEnvironment('signUpUrl');
    const supportUrl = String.fromEnvironment('supportUrl');

    return Brand(
      identifier: const String.fromEnvironment('identifier'),
      appId: const String.fromEnvironment('appId'),
      appName: const String.fromEnvironment('appName'),
      url: Uri.parse(const String.fromEnvironment('url')),
      middlewareUrl: Uri.parse(const String.fromEnvironment('middlewareUrl')),
      voipgridUrl: Uri.parse(const String.fromEnvironment('voipgridUrl')),
      sipUrl: Uri.parse(const String.fromEnvironment('sipUrl')),
      businessAvailabilityUrl: Uri.parse(
        const String.fromEnvironment('businessAvailabilityUrl'),
      ),
      openingHoursBasicUrl: Uri.parse(
        const String.fromEnvironment('openingHoursBasicUrl'),
      ),
      privacyPolicyUrl: Uri.parse(
        const String.fromEnvironment('privacyPolicyUrl'),
      ),
      signUpUrl: signUpUrl.isNotEmpty ? Uri.parse(signUpUrl) : null,
      availabilityServiceUrl: Uri.parse(
        const String.fromEnvironment('availabilityServiceUrl'),
      ),
      sharedContactsUrl: Uri.parse(
        const String.fromEnvironment('sharedContactsUrl'),
      ),
      phoneNumberValidationUrl: Uri.parse(
        const String.fromEnvironment('phoneNumberValidationUrl'),
      ),
      featureAnnouncementsUrl: Uri.parse(
        const String.fromEnvironment('featureAnnouncementsUrl'),
      ),
      resgateUrl: Uri.parse(
        const String.fromEnvironment('resgateUrl'),
      ),
      supportUrl: supportUrl.isNotNullOrBlank ? Uri.parse(supportUrl) : null,
    );
  }
}
