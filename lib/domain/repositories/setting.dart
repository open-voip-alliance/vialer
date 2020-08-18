import '../../domain/entities/setting.dart';

import '../../domain/repositories/storage.dart';

class SettingRepository {
  final StorageRepository _storageRepository;

  SettingRepository(this._storageRepository);

  Future<void> resetToDefaults() async {
    _storageRepository.settings = [
      RemoteLoggingSetting(false),
      ShowDialerConfirmPopupSetting(true),
    ];

    return null;
  }

  Future<List<Setting>> getSettings() async {
    return _storageRepository.settings;
  }

  Future<void> changeSetting(Setting setting) async {
    final settings = await getSettings();

    final newSettings = settings.toList();

    for (final s in settings) {
      if (s.runtimeType == setting.runtimeType) {
        newSettings.remove(s);
        newSettings.add(setting);
      }
    }

    _storageRepository.settings = newSettings;
  }
}
