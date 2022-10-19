import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/settings/app_setting.dart';
import '../events/event_bus.dart';
import '../events/user_was_logged_out.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'client_calls/purge_local_call_records.dart';
import 'get_logged_in_user.dart';
import 'stop_voip.dart';

class LogoutUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _eventBus = dependencyLocator<EventBus>();

  final _getUser = GetLoggedInUserUseCase();
  final _stopVoip = StopVoipUseCase();
  final _purgeClientCalls = PurgeLocalCallRecordsUseCase();

  Future<void> call() async {
    await _stopVoip();

    await _clearStorage();
  }

  /// Clear the storage of all user-specific values.
  Future<void> _clearStorage() async {
    // Settings that we want to save across sessions.
    final pushToken = _storageRepository.pushToken;
    final remoteNotificationToken = _storageRepository.remoteNotificationToken;
    final crossSessionSettings = _getUser().settings.getAll([
      AppSetting.remoteLogging,
    ]);

    await _storageRepository.clear();

    _storageRepository.pushToken = pushToken;
    _storageRepository.remoteNotificationToken = remoteNotificationToken;
    _storageRepository.previousSessionSettings = crossSessionSettings;

    await _purgeClientCalls(reason: PurgeReason.logout);

    _eventBus.broadcast(const UserWasLoggedOutEvent());
  }
}
