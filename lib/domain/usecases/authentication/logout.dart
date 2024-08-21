import 'dart:async';

import '../../../data/models/event/event_bus.dart';
import '../../../data/repositories/legacy/storage.dart';
import '../../../dependency_locator.dart';
import '../calling/voip/stop_voip.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import '../user/settings/clear_and_preserve_cross_session_settings.dart';
import 'user_was_logged_out.dart';

class Logout extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _eventBus = dependencyLocator<EventBus>();

  final _getUser = GetLoggedInUserUseCase();
  final _stopVoip = StopVoipUseCase();
  final _preserveCrossSessionSettings =
      ClearStorageAndPreserveCrossSessionSettings();

  Future<void> call() async {
    await _stopVoip();

    await _clearStorage();
  }

  /// Clear the storage of all user-specific values.
  Future<void> _clearStorage() async {
    final pushToken = _storageRepository.pushToken;
    final remoteNotificationToken = _storageRepository.remoteNotificationToken;
    final user = _getUser();

    await _preserveCrossSessionSettings(user);

    _storageRepository
      ..pushToken = pushToken
      ..remoteNotificationToken = remoteNotificationToken;

    _eventBus.broadcast(const UserWasLoggedOutEvent());
  }
}
