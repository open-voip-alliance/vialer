import 'package:dartx/dartx.dart';

import '../../../data/API/authentication/unauthorized_api_response.dart';
import '../onboarding/is_onboarded.dart';
import '../use_case.dart';
import 'logout.dart';

class LogoutOnUnauthorizedResponse extends UseCase {
  final _logout = Logout();
  final _isOnboarded = IsOnboarded();

  Future<void> call(UnauthorizedApiResponseEvent event) async {
    if (!_isOnboarded()) return;

    if (!isUrlThatShouldTriggerLogout(event.url)) return;

    logger.warning(
      'Logging unauthorized user out, code was: ${event.statusCode}.',
    );

    return _logout();
  }

  /// We only want to log the user out if they have received an unauthorized
  /// response from a specific set of urls.
  bool isUrlThatShouldTriggerLogout(String responseUrl) => const [
        'permission/systemuser/profile',
        'permission/apitoken',
      ].filter((url) => responseUrl.contains(url)).isNotEmpty;
}
