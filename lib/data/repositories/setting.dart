import '../../domain/entities/setting.dart';
import '../../domain/repositories/setting.dart';

import '../../domain/repositories/storage.dart';

class DataSettingRepository extends SettingRepository {
  final StorageRepository _storageRepository;

  DataSettingRepository(this._storageRepository);

  @override
  Future<void> resetToDefaults() async {
    _storageRepository.settings = [
      RemoteLoggingSetting(false),
      ShowDialerConfirmPopupSetting(true),
    ];

    return null;
  }

  @override
  Future<List<Setting>> getSettings() async {
    return _storageRepository.settings;
  }

  @override
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
