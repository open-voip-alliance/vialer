import '../../domain/entities/setting.dart';

import '../../domain/repositories/storage.dart';

class SettingRepository {
  final StorageRepository _storageRepository;

  SettingRepository(this._storageRepository);

  Future<List<Setting>> getSettings() async {
    return _storageRepository.settings;
  }

  Future<void> changeSetting(Setting setting) async {
    final settings = await getSettings();

    final newSettings = settings.toList();

    var changed = false;
    for (final s in settings) {
      if (s.runtimeType == setting.runtimeType) {
        newSettings.remove(s);
        newSettings.add(setting);
        changed = true;
        break;
      }
    }

    if (!changed) {
      newSettings.add(setting);
    }

    _storageRepository.settings = newSettings;
  }
}
