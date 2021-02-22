import 'package:meta/meta.dart';

import '../entities/exceptions/auto_login.dart';
import '../entities/exceptions/need_to_change_password.dart';
import '../entities/system_user.dart';
import '../repositories/storage.dart';
import 'services/voipgrid.dart';

class AuthRepository {
  final StorageRepository _storageRepository;
  final VoipgridService _service;

  AuthRepository(this._storageRepository, this._service);

  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _apiTokenKey = 'api_token';

  SystemUser _currentUser;

  /// Fetches the latest user from the portal.
  Future<SystemUser> fetchLatestUser() async {
    final systemUserResponse = await _service.getSystemUser();
    if (systemUserResponse.error
        .toString()
        .contains('You need to change your password in the portal')) {
      throw NeedToChangePasswordException();
    }

    return _currentUser = _storageRepository.systemUser = SystemUser.fromJson(
      systemUserResponse.body as Map<String, dynamic>,
    ).copyWith(
      token: _currentUser.token,
    );
  }

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

      await fetchLatestUser();

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

  Future<String> fetchAutoLoginToken() async {
    final response = await _service.getAutoLoginToken();
    if (!response.isSuccessful) {
      throw AutoLoginException();
    }
    final body = response.body as Map<String, dynamic>;
    return body['token'] as String;
  }
}
