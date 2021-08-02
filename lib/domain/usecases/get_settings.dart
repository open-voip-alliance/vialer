import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/storage.dart';
import '../use_case.dart';
import 'get_user.dart';

class GetSettingsUseCase extends UseCase {
  final _storageRepository = dependencyLocator<StorageRepository>();

  final _getUser = GetUserUseCase();

  Future<List<Setting>> call() async {
    final user = await _getUser(latest: false);
    final storedSettings = _storageRepository.settings;

    return [
      ...storedSettings,
      // Add presets for which no stored setting is found.
      ...Setting.presets.where(
        (s) => !storedSettings.any(
          (stored) => stored.runtimeType == s.runtimeType,
        ),
      ),
      if (user?.outgoingCli != null) BusinessNumberSetting(user!.outgoingCli!),
      MobileNumberSetting(user!.mobileNumber!),
    ];
  }
}
