import 'dart:async';

import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../entities/login_credentials.dart';
import '../entities/settings/app_setting.dart';
import '../entities/settings/call_setting.dart';
import '../entities/settings/settings.dart';
import '../entities/user.dart';
import '../entities/user_permissions.dart';
import '../repositories/auth.dart';
import '../repositories/destination.dart';
import '../repositories/outgoing_numbers.dart';
import '../repositories/storage.dart';
import '../repositories/user_permissions.dart';
import '../use_case.dart';
import 'client_calls/purge_local_call_records.dart';

class GetLatestUserUseCase extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _outgoingNumbersRepository =
      dependencyLocator<OutgoingNumbersRepository>();
  final _userPermissionsRepository =
      dependencyLocator<UserPermissionsRepository>();

  final _purgeLocalCallRecords = PurgeLocalCallRecordsUseCase();

  Future<User?> call([LoginCredentials? credentials]) async {
    final storedUser = _storageRepository.user;
    final latestUser = await _getUserFromCredentials(credentials);

    if (latestUser == null) return storedUser;

    // Latest user contains some settings, such as mobile and outgoing number.
    var user = storedUser?.copyFrom(latestUser) ??
        latestUser.copyWith(
          settings: const Settings.defaults().copyFrom(latestUser.settings),
        );

    // If we're retrieving the user for the first time (logging in), we store
    // the user already, so that the AuthorizationInterceptor can use it.
    if (storedUser == null) {
      _storageRepository.user = user;
    }

    user = _getPreviousSessionSettings(user);
    user = await _getRemoteSettings(user);
    user = await _getRemotePermissions(user);
    user = await _getRemoteClientOutgoingNumbers(user);

    // User should have a value for all settings.
    assert(
      user.settings.isComplete,
      'The following settings are missing from the user: '
      '${Settings.possibleKeys.difference(user.settings.keys).toList()}',
    );

    _storageRepository.user = user;

    return user;
  }

  Future<User?> _getUserFromCredentials(LoginCredentials? credentials) async {
    if (credentials is UserProvidedCredentials) {
      return await _authRepository.authenticate(
        credentials.email,
        credentials.password,
        twoFactorCode: credentials.twoFactorCode,
      );
    }

    if (credentials is ImportedLegacyAppCredentials) {
      return await _authRepository.getUserUsingProvidedCredentials(
        email: credentials.email,
        token: credentials.token,
      );
    }

    return await _authRepository.getUserUsingStoredCredentials();
  }

  /// Retrieving settings and handling its possible side effects.
  Future<User> _getRemoteSettings(User user) async {
    return user.copyWith(
      settings: user.settings.copyWithAll({
        CallSetting.useMobileNumberAsFallback:
            await _authRepository.isUserUsingMobileNumberAsFallback(user),
        // TODO: Empty availability instead of non-null assert
        CallSetting.availability:
            (await _destinationRepository.getLatestAvailability())!,
      }),
    );
  }

  /// Retrieving permissions and handling its possible side effects.
  Future<User> _getRemotePermissions(User user) async {
    final clientCallsVgPermission =
        await _userPermissionsRepository.hasPermission(
      type: UserPermission.clientCalls,
      user: user,
    );

    final mobileNumberFallbackPermission =
        await _userPermissionsRepository.hasPermission(
      type: UserPermission.mobileNumberFallback,
      user: user,
    );

    // If we are unable to get the current permissions we should just leave
    // the current permission as it is.
    if (clientCallsVgPermission == PermissionResult.unavailable ||
        mobileNumberFallbackPermission == PermissionResult.unavailable) {
      return user;
    }

    final permissions = UserPermissions(
      canSeeClientCalls: clientCallsVgPermission == PermissionResult.granted,
      canUseMobileNumberFallback:
          mobileNumberFallbackPermission == PermissionResult.granted,
    );

    if (!permissions.canSeeClientCalls) {
      _purgeLocalCallRecords(reason: PurgeReason.permissionFailed);
    }

    // If a user loses permission we want to disable this setting.
    if (!permissions.canSeeClientCalls) {
      final key = AppSetting.showClientCalls;
      final showClientCalls = user.settings.get(key);

      if (showClientCalls) {
        user = user.copyWith(settings: user.settings.copyWith(key, false));
      }
    }

    return user.copyWith(
      permissions: permissions,
    );
  }

  /// Retrieving client outgoing numbers and handling its possible side effects.
  Future<User> _getRemoteClientOutgoingNumbers(User user) async {
    if (user.client == null) return user;

    if (!user.canChangeOutgoingNumber) {
      logger.warning('Unable to get client outgoing numbers as no client_uuid');
      return user;
    }

    return user.copyWith(
      client: user.client?.copyWith(
        outgoingNumbers: await _outgoingNumbersRepository
            .getOutgoingNumbersAvailableToClient(user: user),
      ),
    );
  }

  User _getPreviousSessionSettings(User user) {
    final previousSessionSettings = _storageRepository.previousSessionSettings;

    if (!previousSessionSettings.isEmpty) {
      // We clear it after use, so it doesn't override settings in the future.
      _storageRepository.previousSessionSettings = null;
      return user.copyWith(
        settings: user.settings.copyFrom(previousSessionSettings),
      );
    }

    return user;
  }
}
