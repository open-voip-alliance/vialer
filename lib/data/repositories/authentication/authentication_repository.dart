import 'package:chopper/chopper.dart';
import 'package:injectable/injectable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vialer/data/models/user/settings/call_setting.dart';

import '../../../domain/usecases/user/settings/force_update_settings.dart';
import '../../../presentation/util/automatic_retry.dart';
import '../../../presentation/util/loggable.dart';
import '../../API/voipgrid/voipgrid_service.dart';
import '../../models/calling/outgoing_number/outgoing_number.dart';
import '../../models/onboarding/auto_login.dart';
import '../../models/onboarding/exceptions.dart';
import '../../models/onboarding/login_credentials.dart';
import '../../models/onboarding/two_factor_authentication_required.dart';
import '../../models/user/client.dart';
import '../../models/user/user.dart';
import '../../models/voipgrid/client_voip_config.dart';

part 'authentication_repository.g.dart';

@singleton
class AuthRepository with Loggable {
  AuthRepository(this._service);

  final VoipgridService _service;
  final mobileNumberRetry = AutomaticRetry.http('Change Mobile Number');
  final useMobileNumberAsFallbackRetry = AutomaticRetry.http(
    'Use Mobile Number As Fallback',
  );

  static const _emailKey = 'email';
  static const _passwordKey = 'password';
  static const _apiTokenKey = 'api_token';
  static const _twoFactorKey = 'two_factor_token';

  Future<User?> getUserFromCredentials(LoginCredentials? credentials) async {
    if (credentials is UserProvidedCredentials) {
      return _authenticate(
        credentials.email,
        credentials.password,
        twoFactorCode: credentials.twoFactorCode,
      );
    }

    if (credentials is ImportedLegacyAppCredentials) {
      return _getUserUsingProvidedCredentials(
        email: credentials.email,
        token: credentials.token,
      );
    }

    try {
      return _getUserUsingStoredCredentials();
    } on FailedToRetrieveUserException {
      return null;
    }
  }

  /// Returns the latest user from the portal.
  Future<User> _getUserUsingStoredCredentials() => _getUser();

  Future<User> _getUserUsingProvidedCredentials({
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
      'Either email or token must be passed',
    );

    try {
      final response = await _service.getSystemUser(
        authorization:
            email != null && token != null ? 'Token $email:$token' : null,
      );

      if (response.error
          .toString()
          .contains('You need to change your password in the portal')) {
        throw NeedToChangePasswordException();
      }

      final systemUser = _SystemUserResponse.fromJson(
        response.body!,
      );

      ForceUpdateSettings()(
        {
          CallSetting.mobileNumber: systemUser.mobileNumber ?? '',
          CallSetting.outgoingNumber:
              OutgoingNumber.fromJson(systemUser.outgoingCli ?? ''),
        },
      );

      return systemUser.toUser();
    } on ChopperHttpException catch (e) {
      logFailedResponse(e.response, name: 'Fetch User');
      throw FailedToRetrieveUserException(
        statusCode: e.response.statusCode,
        error: e.response.error.toString(),
      );
    } catch (e) {
      logger.severe('Failed to retrieve user: $e');
      throw FailedToRetrieveUserException();
    }
  }

  /// If null is returned, authentication failed.
  Future<User?> _authenticate(
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

    final body = tokenResponse.body;

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
      await _authenticate(email, newPassword, cachePassword: false);

      return true;
    } else {
      return false;
    }
  }

  /// Requests a new password for the user with the given [email].
  /// Returns a [Future] that completes with a [bool] indicating whether the request was successful or not.
  Future<bool> requestNewPassword({
    required String email,
  }) =>
      _service.requestNewPassword({
        'email': email,
      }).then((response) => response.isSuccessful);

  Future<String> getAutoLoginToken() async {
    final response = await _service.getAutoLoginToken();
    if (!response.isSuccessful) {
      throw AutoLoginException();
    }
    final body = response.body!;
    return body['token'] as String;
  }

  Future<bool> changeMobileNumber(String mobileNumber) async {
    try {
      await mobileNumberRetry.run(() async {
        final response =
            await _service.changeMobileNumber({'mobile_nr': mobileNumber});

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

  Future<bool> updateAppAccount({
    required bool useOpus,
    required bool useEncryption,
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

    final body = response.body!;
    final app = body['app'] as Map<String, dynamic>;

    return app['use_mobile_number_as_fallback'] as bool;
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

        final app = settingsResponse.body!['app'] as Map<String, dynamic>;

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
                'id': (app['voip_account'] as Map<String, dynamic>)['id'],
              },
            },
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
  const _SystemUserResponse({
    required this.firstName,
    required this.preposition,
    required this.lastName,
    required this.clientId,
    required this.clientUuid,
    required this.clientName,
    required this.clientUrl,
    required this.uuid,
    required this.email,
    this.mobileNumber,
    this.appAccountUrl,
    this.outgoingCli,
  });

  factory _SystemUserResponse.fromJson(Map<String, dynamic> json) =>
      _$SystemUserResponseFromJson(json);
  final String uuid;

  final String email;

  @JsonKey(name: 'mobile_nr')
  final String? mobileNumber;

  final String firstName;
  final String preposition;
  final String lastName;

  @JsonKey(name: 'app_account')
  final Uri? appAccountUrl;

  final String? outgoingCli;

  final int clientId;
  final String clientUuid;
  final String clientName;

  @JsonKey(name: 'client')
  final Uri clientUrl;

  User toUser() => User(
        uuid: uuid,
        email: email,
        firstName: firstName,
        preposition: preposition,
        lastName: lastName,
        appAccountUrl: appAccountUrl,
        client: Client(
          id: clientId,
          uuid: clientUuid,
          name: clientName,
          url: clientUrl,
          voip: ClientVoipConfig.fallback(),
        ),
      );
}
