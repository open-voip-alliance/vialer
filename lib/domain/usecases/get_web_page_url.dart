import '../../dependency_locator.dart';
import '../entities/system_user.dart';
import '../entities/web_page.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_brand.dart';
import 'get_user.dart';

class GetWebPageUrlUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getBrand = GetBrandUseCase();
  final _getUser = GetUserUseCase();

  /// The url that the webview will load, it is possible to add placeholders
  /// in-between curly brackets (e.g. {client}) and the client id will be
  /// replaced in [replacePlaceholders].
  final _pagePathMapping = {
    WebPage.dialPlan: '/dialplan/',
    WebPage.stats: '/stats/dashboard/',
    WebPage.passwordReset: '/user/password_reset/',
    WebPage.addDestination: '/fixeddestination/add/',
    WebPage.calls: '/client/{client}/call/',
  };

  final _unauthenticatedPages = [WebPage.passwordReset];

  Future<String> call({required WebPage page}) async {
    final brand = await _getBrand();

    // Unauthenticated portal page.
    if (_unauthenticatedPages.contains(page)) {
      return brand.url.replace(path: _pagePathMapping[page]).toString();
    }

    // Authenticated portal page.
    final user = await _getUser(latest: false);
    final autoLoginToken = await _authRepository.getAutoLoginToken();
    final username = user!.email;
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
    required SystemUser user,
  }) {
    if (url == null) return null;

    // The client id should only ever be null if the user has an old
    // [SystemUser] cached.
    assert(user.clientId != null);

    // All the values from the url within curly brackets will be replaced
    // with the corresponding user information.
    final placeholders = {
      'client': user.clientId,
    };

    for (final placeholder in placeholders.entries) {
      final target = placeholder.key;
      final replacement = placeholder.value;

      if (replacement == null || replacement.isEmpty) continue;

      url = url?.replaceAll('{$target}', replacement);
    }

    return url;
  }
}
