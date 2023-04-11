import 'dart:async';

import '../../app/pages/main/settings/widgets/tile/availability.dart';
import '../../app/util/loggable.dart';
import '../../app/util/synchronized_task.dart';
import '../../dependency_locator.dart';
import '../authentication/authentication_repository.dart';
import '../business_availability/temporary_redirect/get_current_temporary_redirect.dart';
import '../business_availability/temporary_redirect/temporary_redirect.dart';
import '../call_records/client/purge_local_call_records.dart';
import '../calling/outgoing_number/outgoing_numbers.dart';
import '../calling/voip/client_voip_config_repository.dart';
import '../calling/voip/destination_repository.dart';
import '../calling/voip/user_voip_config_repository.dart';
import '../event/event_bus.dart';
import '../legacy/storage.dart';
import '../metrics/metrics.dart';
import '../onboarding/exceptions.dart';
import '../onboarding/login_credentials.dart';
import '../openings_hours_basic/get_opening_hours_modules.dart';
import '../openings_hours_basic/opening_hours.dart';
import '../openings_hours_basic/should_show_opening_hours_basic.dart';
import '../use_case.dart';
import '../voicemail/voicemail_account.dart';
import '../voicemail/voicemail_account_repository.dart';
import '../voipgrid/client_voip_config.dart';
import '../voipgrid/user_permissions.dart';
import '../voipgrid/user_voip_config.dart';
import 'events/logged_in_user_was_refreshed.dart';
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
  final _eventBus = dependencyLocator<EventBus>();

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
    Future<User?> executeUserRefreshTasks() async {
      final storedUser = _storageRepository.user;
      final latestUser = await _getUserFromCredentials(credentials);

      if (latestUser == null) return storedUser;

      // Latest user contains some settings, such as mobile and
      // outgoing number.
      var user = storedUser?.copyFrom(latestUser) ?? latestUser;

      user = user.copyWith(
        settings: Settings.defaults.copyFrom(user.settings),
        permissions: storedUser?.permissions,
        client: storedUser?.client,
        voip: storedUser?.voip,
      );

      // If we're retrieving the user for the first time (logging in),
      // we store the user already, so that the AuthorizationInterceptor
      // can use it.
      if (storedUser == null) {
        _storageRepository.user = user;
      }

      user = _getPreviousSessionSettings(user);

      final hasAppAccount = _storageRepository.availableDestinations
              .findAppAccountFor(user: user) !=
          null;

      // Users without an app account should have VoIP disabled.
      if (!hasAppAccount) {
        user = user.copyWith(
          settings: user.settings.copyWith(CallSetting.useVoip, false),
        );
      }

      user = await tasksToRun.runOr(
        UserRefreshTask.remotePermissions,
        user,
        fallback: user,
        () => _getRemotePermissions(user),
      );

      final clientOutgoingNumbers = tasksToRun.run(
        UserRefreshTask.remoteClientOutgoingNumbers,
        user,
        () => _getRemoteClientOutgoingNumbers(user),
      );

      final clientVoicemailAccounts = tasksToRun.run(
        UserRefreshTask.remoteClientVoicemailAccounts,
        user,
        () => _getClientVoicemailAccounts(user),
      );

      final clientVoipConfig = tasksToRun.run(
        UserRefreshTask.clientVoipConfig,
        user,
        () => _getClientVoipConfig(user),
      );

      final currentTemporaryRedirect = tasksToRun.run(
        UserRefreshTask.currentTemporaryRedirect,
        user,
        () => _getCurrentTemporaryRedirect(user),
      );

      final userVoipConfig = tasksToRun.run(
        UserRefreshTask.userVoipConfig,
        user,
        () => _getUserVoipConfig(user),
      );

      // These will be executed last, as these are the most important settings
      // to have as fresh as possible for the best user experience.
      final remoteSettings = tasksToRun.runOr(
        UserRefreshTask.remoteSettings,
        user,
        fallback: const <SettingKey, Object>{},
        () => _getRemoteSettings(user),
      );

      final availability = tasksToRun.runOr(
        UserRefreshTask.availability,
        user,
        fallback: const <SettingKey, Object>{},
        () => _getAvailability(user),
      );

      final openingHoursModules = tasksToRun.run(
        UserRefreshTask.openingHours,
        user,
        () => _getOpeningHours(user),
      );

      await Future.wait([
        clientOutgoingNumbers,
        clientVoicemailAccounts,
        clientVoipConfig,
        currentTemporaryRedirect,
        userVoipConfig,
        remoteSettings,
        availability,
        openingHoursModules,
      ]);

      // All the 'await's are a formality here, the futures have been completed.
      user = user.copyWith(
        client: user.client.copyWith(
          outgoingNumbers: await clientOutgoingNumbers,
          voicemailAccounts: await clientVoicemailAccounts,
          voip: await clientVoipConfig,
          currentTemporaryRedirect: await currentTemporaryRedirect,
          openingHoursModules: await openingHoursModules,
        ),
        voip: await userVoipConfig,
        settings: user.settings.copyWithAll({
          ...(await availability),
          ...(await remoteSettings),
        }),
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

      _eventBus.broadcast(LoggedInUserWasRefreshed(user));

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

  Future<Map<SettingKey, Object>> _getAvailability(
    User user,
  ) async {
    final destination = await _destinationRepository.getActiveDestination();

    return destination.maybeWhen(
      unknown: () => const {},
      orElse: () => {CallSetting.destination: destination},
    );
  }

  Future<Map<SettingKey, Object>> _getRemoteSettings(User user) async {
    final useMobileNumberAsFallback =
        await _authRepository.isUserUsingMobileNumberAsFallback(user);

    return {
      CallSetting.useMobileNumberAsFallback: useMobileNumberAsFallback,
    };
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
      canViewDialPlans: granted.contains(UserPermission.viewRouting),
      canViewStats: granted.contains(UserPermission.viewStats),
      canChangeOpeningHours:
          granted.contains(UserPermission.changeOpeningHours),
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
  Future<Iterable<OutgoingNumber>> _getRemoteClientOutgoingNumbers(User user) =>
      _outgoingNumbersRepository.getOutgoingNumbersAvailableToClient(
          user: user);

  /// Retrieving client outgoing numbers and handling its possible side effects.
  Future<List<VoicemailAccount>> _getClientVoicemailAccounts(User user) =>
      _voicemailRepository.getVoicemailAccounts(user: user);

  /// Retrieving user voip config and handling its possible side effects.
  Future<UserVoipConfig?> _getUserVoipConfig(User user) =>
      _userVoipConfigRepository.get();

  /// Retrieving user voip config and handling its possible side effects.
  Future<ClientVoipConfig?> _getClientVoipConfig(User user) async {
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

      return latest;
    }

    return null;
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

  Future<TemporaryRedirect?> _getCurrentTemporaryRedirect(User user) =>
      GetCurrentTemporaryRedirect()();

  Future<List<OpeningHoursModule>> _getOpeningHours(User user) =>
      GetOpeningHoursModules()();
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
  openingHours,
}

extension on List<UserRefreshTask> {
  /// Conditionally run the refresh task if it appears in our list of
  /// tasks to complete.
  Future<T?> run<T>(
    UserRefreshTask task,
    User user,
    Future<T> Function() callback,
  ) async =>
      contains(task) && user.hasPermissionFor(task) ? await callback() : null;

  /// Conditionally run the refresh task if it appears in our list of
  /// tasks to complete, or returns [fallback] if it doesn't.
  Future<T> runOr<T>(
    UserRefreshTask task,
    User user,
    Future<T> Function() callback, {
    required T fallback,
  }) async =>
      contains(task) && user.hasPermissionFor(task)
          ? await callback()
          : fallback;

  bool get shouldSkipSynchronization => length <= 2;
}

extension on User {
  bool hasPermissionFor(UserRefreshTask task) {
    switch (task) {
      case UserRefreshTask.remoteClientVoicemailAccounts:
        return permissions.canViewVoipAccounts;
      case UserRefreshTask.currentTemporaryRedirect:
        return permissions.canChangeTemporaryRedirect;
      case UserRefreshTask.remoteSettings:
        return permissions.canViewMobileNumberFallbackStatus;
      case UserRefreshTask.openingHours:
        return ShouldShowOpeningHoursBasic()();
      default:
        return true;
    }
  }
}
