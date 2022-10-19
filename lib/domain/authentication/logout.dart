import 'dart:async';

import '../../dependency_locator.dart';
import '../call_records/client/purge_local_call_records.dart';
import '../calling/voip/stop_voip.dart';
import '../event/event_bus.dart';
import '../legacy/storage.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import '../user/settings/app_setting.dart';
import 'user_was_logged_out.dart';

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
