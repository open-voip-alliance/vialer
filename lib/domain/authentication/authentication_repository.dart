import 'package:json_annotation/json_annotation.dart';

import '../../app/util/loggable.dart';
import '../onboarding/auto_login.dart';
import '../onboarding/exceptions.dart';
import '../onboarding/two_factor_authentication_required.dart';
import '../user/client.dart';
import '../user/settings/call_setting.dart';
import '../user/settings/settings.dart';
import '../user/user.dart';
import '../voipgrid/client_voip_config.dart';
import '../voipgrid/voipgrid_service.dart';

part 'authentication_repository.g.dart';

class AuthRepository with Loggable {
  final VoipgridService _service;

  AuthRepository(this._service);

  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _apiTokenKey = 'api_token';
  static const _twoFactorKey = 'two_factor_token';

  /// Returns the latest user from the portal.
  Future<User> getUserUsingStoredCredentials() => _getUser();

  Future<User> getUserUsingProvidedCredentials({
    required String email,
    required String token,
  }) =>
      _getUser(
        email: email,
        token: token,
      );

  Future<User> _getUser({String? email, String? token}) async {
    assert(
      (email == null && token == null) || (email != null && token != null),
    );

    final response = await _service.getSystemUser(
      authorization:
          email != null && token != null ? 'Token $email:$token' : null,
    );

    if (response.error
        .toString()
        .contains('You need to change your password in the portal')) {
      throw NeedToChangePasswordException();
    }

    if (!response.isSuccessful) {
      logFailedResponse(response, name: 'Fetch User');
      throw FailedToRetrieveUserException();
    }

    return _SystemUserResponse.fromJson(
      response.body as Map<String, dynamic>,
    ).toUser();
  }

  /// If null is returned, authentication failed.
  Future<User?> authenticate(
    String email,
    String password, {
    bool cachePassword = true,
    String? twoFactorCode,
  }) async {
    final requestData = {
      _emailKey: email,
      _passwordKey: password,
    };

    if (twoFactorCode != null) {
      requestData[_twoFactorKey] = twoFactorCode;
    }

    final tokenResponse = await _service.getToken(requestData);

    final body = tokenResponse.body as Map<String, dynamic>?;

    if (twoFactorCode == null &&
        tokenResponse.error.toString().contains('two_factor_token')) {
      throw TwoFactorAuthenticationRequiredException();
    }

    if (body != null && body.containsKey(_apiTokenKey)) {
      final token = body[_apiTokenKey] as String;
      final user = await _getUser(email: email, token: token);

      return user.copyWith(token: token);
    } else {
      logger.severe(
        'Authentication failed: '
        '${tokenResponse.statusCode} ${tokenResponse.error}',
      );
    }

    return null;
  }

  Future<bool> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
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

  Future<bool> changeMobileNumber(String mobileNumber) async {
    final response =
        await _service.changeMobileNumber({'mobile_nr': mobileNumber});
    return response.isSuccessful;
  }

  Future<bool> updateAppAccount({
    bool useOpus = true,
    bool useEncryption = true,
  }) async {
    final response = await _service.updateMobileProfile({
      'appaccount_use_opus': useOpus,
      'appaccount_use_encryption': useEncryption,
    });

    logFailedResponse(response);

    return response.isSuccessful;
  }

  Future<bool> isUserUsingMobileNumberAsFallback(User user) async {
    final response = await _service.getUserSettings(
      clientId: user.client.id.toString(),
      userId: user.uuid,
    );

    if (!response.isSuccessful) {
      logger.warning(
        'Unable to determine mobile number fallback: '
        '${response.statusCode} - ${response.bodyString}',
      );
      return false;
    }

    return response.body['app']['use_mobile_number_as_fallback'] as bool;
  }

  Future<bool> setUseMobileNumberAsFallback(
    User user, {
    required bool enable,
  }) async {
    final response = await _service.updateUserSettings(
        clientId: user.client.id.toString(),
        userId: user.uuid,
        body: {
          'app': {
            'use_mobile_number_as_fallback': enable,
          }
        });

    logFailedResponse(response);

    // There is a bug when using the above API that disables encryption on
    // the voip account, so when changing this setting we need to manually
    // enable it again.
    //
    // TODO: Remove this when the webapp bug is fixed.
    await updateAppAccount(
      useOpus: true,
      useEncryption: true,
    );

    return response.isSuccessful;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class _SystemUserResponse {
  final String uuid;

  final String email;

  @JsonKey(name: 'mobile_nr')
  final String? mobileNumber;

  final String firstName;
  final String lastName;

  @JsonKey(name: 'app_account')
  final Uri? appAccountUrl;

  final String? outgoingCli;

  final int clientId;
  final String clientUuid;
  final String clientName;

  @JsonKey(name: 'client')
  final Uri clientUrl;

  const _SystemUserResponse({
    required this.uuid,
    required this.email,
    this.mobileNumber,
    required this.firstName,
    required this.lastName,
    this.appAccountUrl,
    this.outgoingCli,
    required this.clientId,
    required this.clientUuid,
    required this.clientName,
    required this.clientUrl,
  });

  factory _SystemUserResponse.fromJson(Map<String, dynamic> json) =>
      _$SystemUserResponseFromJson(json);

  User toUser() => User(
        uuid: uuid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        appAccountUrl: appAccountUrl,
        client: Client(
          id: clientId,
          uuid: clientUuid,
          name: clientName,
          url: clientUrl,
          voip: ClientVoipConfig.fallback(),
        ),
        settings: Settings({
          CallSetting.mobileNumber: mobileNumber ?? '',
          CallSetting.outgoingNumber: OutgoingNumber.fromJson(
            outgoingCli ?? '',
          ),
        }),
      );
}
