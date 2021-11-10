import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../events/event_bus.dart';
import '../events/user_was_logged_out.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'stop_voip.dart';

class LogoutUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();
  final _stopVoip = StopVoipUseCase();
  final _eventBus = dependencyLocator<EventBus>();

  Future<void> call() async {
    await _stopVoip();

    await _clearStorage();
  }

  /// Clear the storage of all user-specific values.
  Future<void> _clearStorage() async {
    final remoteLoggingSetting =
        _storageRepository.settings.getOrNull<RemoteLoggingSetting>();

    final pushToken = _storageRepository.pushToken;

    await _storageRepository.clear();

    _storageRepository.pushToken = pushToken;

    // If the setting was null, it was not set yet, and we leave it like that.
    if (remoteLoggingSetting != null) {
      _storageRepository.settings = [
        remoteLoggingSetting,
      ];
    }

    _eventBus.broadcast(const UserWasLoggedOutEvent());
  }
}
