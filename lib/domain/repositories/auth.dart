import 'package:meta/meta.dart';

import '../entities/exceptions/auto_login.dart';
import '../entities/exceptions/need_to_change_password.dart';
import '../entities/system_user.dart';
import 'services/voipgrid.dart';

class AuthRepository {
  final VoipgridService _service;

  AuthRepository(this._service);

  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _apiTokenKey = 'api_token';

  /// Returns the latest user from the portal.
  Future<SystemUser> getUser() => _getUser();

  Future<SystemUser> _getUser({String email, String token}) async {
    assert(
      (email == null && token == null) || (email != null && token != null),
    );

    final systemUserResponse = await _service.getSystemUser(
      authorization:
          email != null && token != null ? 'Token $email:$token' : null,
    );
    if (systemUserResponse.error
        .toString()
        .contains('You need to change your password in the portal')) {
      throw NeedToChangePasswordException();
    }

    return SystemUser.fromJson(
      systemUserResponse.body as Map<String, dynamic>,
    );
  }

  /// If null is returned, authentication failed.
  Future<SystemUser> authenticate(
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
      final user = await _getUser(email: email, token: token);

      return user.copyWith(token: token);
    }

    return null;
  }

  Future<bool> changePassword({
    @required String email,
    @required String currentPassword,
    @required String newPassword,
  }) async {
    final response = await _service.password({
      'email_address': email,
      'current_password': currentPassword,
      'new_password': newPassword,
    });

    if (response.isSuccessful) {
      await authenticate(email, newPassword, cachePassword: false);

      return true;
    } else {
      return false;
    }
  }

  Future<String> getAutoLoginToken() async {
    final response = await _service.getAutoLoginToken();
    if (!response.isSuccessful) {
      throw AutoLoginException();
    }
    final body = response.body as Map<String, dynamic>;
    return body['token'] as String;
  }
}
