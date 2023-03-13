import 'package:chopper/chopper.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../app/util/automatic_retry.dart';
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
  final mobileNumberRetry = AutomaticRetry.http('Change Mobile Number');
  final useMobileNumberAsFallbackRetry = AutomaticRetry.http(
    'Use Mobile Number As Fallback',
  );

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
    try {
      await mobileNumberRetry.run(() async {
        final response =
            await _service.changeMobileNumber({'mobile_nr': mobileNumber});

        if (!response.isSuccessful) {
          logFailedResponse(response);

          return response.shouldRetry
              ? AutomaticRetryTaskOutput.fail(response)
              : AutomaticRetryTaskOutput.failDoNotRetry(response);
        }

        return AutomaticRetryTaskOutput.success(response);
      });

      return true;
    } on AutomaticRetryMaximumAttemptsReached {
      return false;
    }
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
    try {
      await useMobileNumberAsFallbackRetry.run(() async {
        final settingsResponse = await _service.getUserSettings(
          clientId: user.client.id.toString(),
          userId: user.uuid,
        );

        if (!settingsResponse.isSuccessful) {
          logFailedResponse(
            settingsResponse,
            name: 'Fetching current user to update it',
          );
          return AutomaticRetryTaskOutput.fail(settingsResponse);
        }

        final app = (settingsResponse.body as Map<String, dynamic>)['app'];

        // This API requires us to provide all the content, rather than being
        // able to patch the nested objects. This is why we must perform the
        // request before to fetch the latest data.
        final response = await _service.updateUserSettings(
          clientId: user.client.id.toString(),
          userId: user.uuid,
          body: {
            'app': {
              'mobile_number': app['mobile_number'],
              'use_mobile_number_as_fallback': enable,
              'voip_account': {
                'id': app['voip_account']['id'],
              }
            }
          },
        );

        if (!response.isSuccessful) {
          logFailedResponse(response);
          return AutomaticRetryTaskOutput.fail(response);
        }

        return AutomaticRetryTaskOutput.success(response);
      });

      return true;
    } on AutomaticRetryMaximumAttemptsReached {
      return false;
    }
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
          openingHours: const [],
        ),
        settings: Settings({
          CallSetting.mobileNumber: mobileNumber ?? '',
          CallSetting.outgoingNumber: OutgoingNumber.fromJson(
            outgoingCli ?? '',
          ),
        }),
      );
}

extension on Response {
  /// If we get a response that the request was bad, we likely don't want to
  /// retry it because future requests won't change anything.
  bool get shouldRetry => statusCode != 400;
}
