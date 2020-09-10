import 'package:meta/meta.dart';

import '../../dependency_locator.dart';

import '../../domain/entities/brand.dart';
import '../../domain/entities/need_to_change_password.dart';

import '../../domain/repositories/storage.dart';

import 'services/voipgrid.dart';
import '../../domain/entities/system_user.dart';

class AuthRepository {
  final StorageRepository _storageRepository;
  final VoipgridService _service;

  AuthRepository(
    this._storageRepository,
    Brand brand,
  ) : _service = VoipgridService.create(baseUrl: brand.baseUrl) {
    dependencyLocator.registerSingleton<VoipgridService>(_service);
  }

  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _apiTokenKey = 'api_token';

  SystemUser _currentUser;

  Future<bool> authenticate(
    String email,
    String password, {
    bool cachePassword = true,
  }) async {
    final tokenResponse = await _service.getToken({
      _emailKey: email,
      _passwordKey: password,
    });

    final body = tokenResponse.body as Map<String, dynamic>;

    if (body != null && body.containsKey(_apiTokenKey)) {
      final token = body[_apiTokenKey] as String;

      // Set a temporary system user that the authorization interceptor will
      // use
      _currentUser = SystemUser(
        email: email,
        token: token,
      );

      final systemUserResponse = await _service.getSystemUser();
      if (systemUserResponse.error
          .toString()
          .contains('You need to change your password in the portal')) {
        throw NeedToChangePassword();
      }

      _storageRepository.systemUser = SystemUser.fromJson(
        systemUserResponse.body as Map<String, dynamic>,
      ).copyWith(
        token: token,
      );

      _currentUser = _storageRepository.systemUser;

      return true;
    } else {
      return false;
    }
  }

  SystemUser get currentUser {
    _currentUser ??= _storageRepository.systemUser;

    return _currentUser;
  }

  Future<bool> changePassword({
    @required String currentPassword,
    @required String newPassword,
  }) async {
    final response = await _service.password({
      'email_address': currentUser.email,
      'current_password': currentPassword,
      'new_password': newPassword,
    });

    if (response.isSuccessful) {
      await authenticate(currentUser.email, newPassword, cachePassword: false);

      return true;
    } else {
      return false;
    }
  }
}
