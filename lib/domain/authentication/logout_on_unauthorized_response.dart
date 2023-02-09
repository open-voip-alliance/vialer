import 'package:dartx/dartx.dart';

import '../use_case.dart';
import 'is_authenticated.dart';
import 'logout.dart';
import 'unauthorized_api_response.dart';

class LogoutOnUnauthorizedResponse extends UseCase {
  final _logout = LogoutUseCase();
  final _isAuthenticated = IsAuthenticated();

  Future<void> call(UnauthorizedApiResponseEvent event) async {
    if (!_isAuthenticated()) return;

    if (!isUrlThatShouldTriggerLogout(event.url)) return;

    logger.warning(
      'Logging unauthorized user out, code was: ${event.statusCode}.',
    );

    _logout();
  }

  /// We only want to log the user out if they have received an unauthorized
  /// response from a specific set of urls.
  bool isUrlThatShouldTriggerLogout(String responseUrl) => const [
        'permission/systemuser/profile',
        'permission/apitoken',
      ].filter((url) => responseUrl.contains(url)).isNotEmpty;
}
