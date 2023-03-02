import 'dart:async';

import '../../app/util/loggable.dart';
import '../../app/util/synchronized_task.dart';
import '../../dependency_locator.dart';
import '../authentication/authentication_repository.dart';
import '../business_availability/temporary_redirect/get_current_temporary_redirect.dart';
import '../call_records/client/purge_local_call_records.dart';
import '../calling/outgoing_number/outgoing_numbers.dart';
import '../calling/voip/client_voip_config_repository.dart';
import '../calling/voip/destination.dart';
import '../calling/voip/destination_repository.dart';
import '../calling/voip/user_voip_config_repository.dart';
import '../legacy/storage.dart';
import '../metrics/metrics.dart';
import '../onboarding/exceptions.dart';
import '../onboarding/login_credentials.dart';
import '../use_case.dart';
import '../voicemail/voicemail_account_repository.dart';
import '../voipgrid/user_permissions.dart';
import 'permissions/user_permissions.dart';
import 'settings/app_setting.dart';
import 'settings/call_setting.dart';
import 'settings/settings.dart';
import 'user.dart';

/// With the exception of `UserDataRefresherCubit`, should generally not
/// be called outside of a few select use cases.
class RefreshUser extends UseCase with Loggable {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _authRepository = dependencyLocator<AuthRepository>();
  final _destinationRepository = dependencyLocator<DestinationRepository>();
  final _outgoingNumbersRepository =
      dependencyLocator<OutgoingNumbersRepository>();
  final _userPermissionsRepository =
      dependencyLocator<UserPermissionsRepository>();
  final _voicemailRepository = dependencyLocator<VoicemailAccountsRepository>();
  final _userVoipConfigRepository =
      dependencyLocator<UserVoipConfigRepository>();
  final _clientVoipConfigRepository =
      dependencyLocator<ClientVoipConfigRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  final _purgeLocalCallRecords = PurgeLocalCallRecordsUseCase();

  Future<User?> call({
    LoginCredentials? credentials,
    bool synchronized = true,
    List<UserRefreshTask>? tasksToRun,
  }) {
    final tasks = tasksToRun ?? UserRefreshTask.values;

    if (synchronized) {
      return SynchronizedTask<User?>.named(
        editUserTask,
        SynchronizedTaskMode.queue,
      ).run(() => _refreshUser(credentials, tasks));
    }

    return _refreshUser(credentials, tasks);
  }

  Future<User?> _refreshUser(
    LoginCredentials? credentials,
    List<UserRefreshTask> tasksToRun,
  ) async {
    executeUserRefreshTasks() async {
      final storedUser = _storageRepository.user;
      final latestUser = await _getUserFromCredentials(credentials);

      if (latestUser == null) return storedUser;

      // Latest user contains some settings, such as mobile and
      // outgoing number.
      var user = storedUser?.copyFrom(latestUser) ?? latestUser;

      user = user.copyWith(
        settings: const Settings.defaults().copyFrom(user.settings),
      );

      // If we're retrieving the user for the first time (logging in),
      // we store  the user already, so that the AuthorizationInterceptor
      // can use it.
      if (storedUser == null) {
        _storageRepository.user = user;
      }

      user = _getPreviousSessionSettings(user);

      user = await tasksToRun.run(
        UserRefreshTask.remotePermissions,
        user,
        () => _getRemotePermissions(user),
      );

      user = await tasksToRun.run(
        UserRefreshTask.remoteClientOutgoingNumbers,
        user,
        () => _getRemoteClientOutgoingNumbers(user),
      );

      user = await tasksToRun.run(
        UserRefreshTask.remoteClientVoicemailAccounts,
        user,
        () => _getClientVoicemailAccounts(user),
      );

      user = await tasksToRun.run(
        UserRefreshTask.userVoipConfig,
        user,
        () => _getUserVoipConfig(user),
      );

      user = await tasksToRun.run(
        UserRefreshTask.clientVoipConfig,
        user,
        () => _getClientVoipConfig(user),
      );

      user = await tasksToRun.run(
        UserRefreshTask.currentTemporaryRedirect,
        user,
        () => _getCurrentTemporaryRedirect(user),
      );

      // These will be executed last, as these are the most important settings
      // to have as fresh as possible for the best user experience.
      user = await tasksToRun.run(
        UserRefreshTask.remoteSettings,
        user,
        () => _getRemoteSettings(user),
      );

      user = await tasksToRun.run(
        UserRefreshTask.availability,
        user,
        () => _getAvailability(user),
      );

      // User should have a value for all settings.
      assert(
        user.settings.isComplete,
        // ignore: prefer_interpolation_to_compose_strings
        'The following settings are missing from the user: ' +
            Settings.possibleKeys
                .difference(user.settings.keys)
                .toList()
                .toString(),
      );

      _storageRepository.user = user;

      return user;
    }

    /// If there aren't many tasks in this list we will always execute
    /// immediately rather than managing synchronization.
    return tasksToRun.shouldSkipSynchronization
        ? executeUserRefreshTasks()
        : SynchronizedTask<User?>.of(this).run(executeUserRefreshTasks);
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

    try {
      return await _authRepository.getUserUsingStoredCredentials();
    } on FailedToRetrieveUserException {
      return null;
    }
  }

  Future<User> _getAvailability(User user) async {
    final destination = await _destinationRepository.getActiveDestination();

    if (destination is Unknown) return user;

    return user.copyWith(
      settings: user.settings.copyWith(CallSetting.destination, destination),
    );
  }

  Future<User> _getRemoteSettings(User user) async {
    final useMobileNumberAsFallback =
        await _authRepository.isUserUsingMobileNumberAsFallback(user);

    final settings = user.settings.copyWith(
      CallSetting.useMobileNumberAsFallback,
      useMobileNumberAsFallback,
    );

    return user.copyWith(settings: settings);
  }

  /// Retrieving permissions and handling its possible side effects.
  Future<User> _getRemotePermissions(User user) async {
    late final List<UserPermission> granted;

    try {
      granted = await _userPermissionsRepository.getGrantedPermissions(
        user: user,
      );
    } on UnableToRetrievePermissionsException {
      // If we are unable to get the current permissions we should just leave
      // the current permission as it is.
      return user;
    }

    final permissions = UserPermissions(
      canSeeClientCalls: granted.contains(UserPermission.clientCalls),
      canChangeMobileNumberFallback:
          granted.contains(UserPermission.changeMobileNumberFallback),
      canViewMobileNumberFallbackStatus:
          granted.contains(UserPermission.viewUser),
      // The only redirect target currently is Voicemail, so if the user
      // cannot view Voicemail they can't use the feature.
      canChangeTemporaryRedirect:
          granted.contains(UserPermission.viewVoicemail) &&
              granted.contains(UserPermission.temporaryRedirect),
      canViewVoicemailAccounts: granted.contains(UserPermission.viewVoicemail),
      canChangeOutgoingNumber:
          granted.contains(UserPermission.changeVoipAccount),
      canViewColleagues: granted.contains(UserPermission.listUsers),
      canViewVoipAccounts: granted.contains(UserPermission.listVoipAccounts),
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
  Future<User> _getRemoteClientOutgoingNumbers(User user) async =>
      user.copyWith(
        client: user.client.copyWith(
          outgoingNumbers: await _outgoingNumbersRepository
              .getOutgoingNumbersAvailableToClient(user: user),
        ),
      );

  /// Retrieving client outgoing numbers and handling its possible side effects.
  Future<User> _getClientVoicemailAccounts(User user) async {
    return user.copyWith(
      client: user.client.copyWith(
        voicemailAccounts: await _voicemailRepository.getVoicemailAccounts(
          user: user,
        ),
      ),
    );
  }

  /// Retrieving user voip config and handling its possible side effects.
  Future<User> _getUserVoipConfig(User user) async {
    final latestVoipConfig = await _userVoipConfigRepository.get();

    if (latestVoipConfig != null) {
      return user.copyWith(
        voip: latestVoipConfig,
      );
    }

    return user;
  }

  /// Retrieving user voip config and handling its possible side effects.
  Future<User> _getClientVoipConfig(User user) async {
    final current = user.client.voip;
    final latest = await _clientVoipConfigRepository.get();

    if (current != latest) {
      if (current.isFallback) {
        logger.info('Loaded CLIENT VOIP CONFIG: $latest');
      } else {
        _metricsRepository.track('server-config-changed', {
          'from': current,
          'to': latest,
        });

        logger.info(
          'Switching CLIENT VOIP CONFIG from [$current] to [$latest]',
        );
      }

      return user.copyWith(
        client: user.client.copyWith(
          voip: latest,
        ),
      );
    }

    return user;
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

  Future<User> _getCurrentTemporaryRedirect(User user) async => user.copyWith(
        client: user.client.copyWith(
          currentTemporaryRedirect: await GetCurrentTemporaryRedirect()(),
        ),
      );
}

enum UserRefreshTask {
  remotePermissions,
  remoteClientOutgoingNumbers,
  remoteClientVoicemailAccounts,
  userVoipConfig,
  clientVoipConfig,
  currentTemporaryRedirect,
  availability,
  remoteSettings,
}

extension on List<UserRefreshTask> {
  /// Conditionally run the refresh task if it appears in our list of
  /// tasks to complete.
  Future<User> run(
    UserRefreshTask task,
    User user,
    Future<User> Function() callback,
  ) async =>
      contains(task) ? await callback() : user;

  bool get shouldSkipSynchronization => length <= 2;
}
