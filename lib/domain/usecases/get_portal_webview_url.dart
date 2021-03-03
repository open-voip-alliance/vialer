import 'package:flutter/foundation.dart';

import '../../dependency_locator.dart';
import '../entities/portal_page.dart';
import '../repositories/auth.dart';
import '../use_case.dart';
import 'get_brand.dart';
import 'get_user.dart';

class GetPortalWebViewUrlUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _getBrand = GetBrandUseCase();

  final _getUser = GetUserUseCase();

  final _pagePathMapping = {
    PortalPage.dialPlan: '/dialplan/',
    PortalPage.stats: '/stats/dashboard/',
    PortalPage.passwordReset: '/user/password_reset/',
    PortalPage.addDestination: '/fixeddestination/add/'
  };
  final _unauthenticatedPages = [PortalPage.passwordReset];

  @override
  Future<String> call({@required PortalPage page}) async {
    final brand = await _getBrand();

    if (_unauthenticatedPages.contains(page)) {
      return brand.url.replace(path: _pagePathMapping[page]).toString();
    }

    final user = await _getUser(latest: false);
    final autoLoginToken = await _authRepository.getAutoLoginToken();
    final username = user.email;
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
