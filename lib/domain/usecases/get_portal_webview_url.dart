import 'package:flutter/foundation.dart';

import '../../dependency_locator.dart';

import '../entities/brand.dart';
import '../entities/portal_page.dart';
import '../repositories/auth.dart';
import '../use_case.dart';

class GetPortalWebViewUrlUseCase extends UseCase {
  final _authRepository = dependencyLocator<AuthRepository>();
  final _brand = dependencyLocator<Brand>();

  final _pagePathMapping = {
    PortalPage.dialPlan: '/dialplan/',
    PortalPage.stats: '/stats/dashboard/',
    PortalPage.passwordReset: '/user/password_reset/',
    PortalPage.addDestination: '/fixeddestination/add/'
  };
  final _unauthenticatedPages = [PortalPage.passwordReset];

  @override
  Future<String> call({@required PortalPage page}) async {
    if (_unauthenticatedPages.contains(page)) {
      return _brand.baseUrl.replace(path: _pagePathMapping[page]).toString();
    }

    final autoLoginToken = await _authRepository.fetchAutoLoginToken();
    final username = _authRepository.currentUser.email;
    final queryParams = {
      'username': username,
      'token': autoLoginToken,
      'next': _pagePathMapping[page],
    };
    final portalUrl = _brand.baseUrl.replace(
      path: '/user/autologin/',
      queryParameters: queryParams,
    );

    return portalUrl.toString();
  }
}
