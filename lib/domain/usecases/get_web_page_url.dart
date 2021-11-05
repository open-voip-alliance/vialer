import '../../dependency_locator.dart';
import '../entities/web_page.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_brand.dart';
import 'get_user.dart';

class GetWebPageUrlUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();

  final _getBrand = GetBrandUseCase();
  final _getUser = GetUserUseCase();

  final _pagePathMapping = {
    WebPage.dialPlan: '/dialplan/',
    WebPage.stats: '/stats/dashboard/',
    WebPage.passwordReset: '/user/password_reset/',
    WebPage.addDestination: '/fixeddestination/add/'
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
    final queryParams = {
      'username': username,
      'token': autoLoginToken,
      'next': _pagePathMapping[page],
    };
    final portalUrl = brand.url.replace(
      path: '/user/autologin/',
      queryParameters: queryParams,
    );

    return portalUrl.toString();
  }
}
