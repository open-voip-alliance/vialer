import 'package:dartx/dartx.dart';

import '../../dependency_locator.dart';
import '../authentication/authentication_repository.dart';
import '../use_case.dart';
import '../user/get_brand.dart';
import '../user/get_logged_in_user.dart';
import '../user/user.dart';
import 'web_page.dart';

class GetWebPageUrlUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getBrand = GetBrand();
  final _getUser = GetLoggedInUserUseCase();

  /// The url that the webview will load, it is possible to add placeholders
  /// in-between curly brackets (e.g. {client}) and the client id will be
  /// replaced in [replacePlaceholders].
  final _pagePathMapping = {
    WebPage.dialPlan: '/dialplan/',
    WebPage.stats: '/stats/dashboard/',
    WebPage.passwordReset: '/user/password_reset/',
    WebPage.addDestination: '/fixeddestination/add/',
    WebPage.calls: '/client/{clientId}/call/',
    WebPage.openingHoursBasicList: '/client/{clientUuid}/openinghoursbasic/',
    WebPage.openingHoursBasicEdit:
        '/client/{clientUuid}/openinghoursbasic/{openingHoursUuid}/change/',
    WebPage.addVoicemail: '/client/{clientId}/voicemail/add/',
    WebPage.telephonySettings:
        '/client/{clientId}/user/{userId}/change/#tc0=user-tab-2',
    WebPage.featureAnnouncements: '/featureannouncements?interface=mobile',
  };

  final _unauthenticatedPages = [WebPage.passwordReset];

  Future<String> call({required WebPage page}) async {
    final brand = _getBrand();

    // Unauthenticated portal page.
    if (_unauthenticatedPages.contains(page)) {
      return brand.url.replace(path: _pagePathMapping[page]).toString();
    }

    // Authenticated portal page.
    final user = _getUser();
    final autoLoginToken = await _authRepository.getAutoLoginToken();
    final username = user.email;
    final url = replacePlaceholders(
      url: _pagePathMapping[page],
      user: user,
    );
    final queryParams = {
      'username': username,
      'token': autoLoginToken,
      'next': url,
    };
    final portalUrl = brand.url.replace(
      path: '/user/autologin/',
      queryParameters: queryParams,
    );

    return portalUrl.toString();
  }

  String? replacePlaceholders({
    required String? url,
    required User user,
  }) {
    if (url == null) return null;

    // All the values from the url within curly brackets will be replaced
    // with the corresponding user information.
    final placeholders = {
      'clientId': user.client.id.toString(),
      'clientUuid': user.client.uuid,
      'openingHoursUuid': user.client.openingHoursModules.firstOrNull?.id,
      'userId': user.uuid,
    };

    for (final placeholder in placeholders.entries) {
      final target = placeholder.key;
      final replacement = placeholder.value;

      if (replacement.isNullOrEmpty) continue;

      url = url?.replaceAll('{$target}', replacement!);
    }

    return url;
  }
}
