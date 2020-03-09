import '../../domain/entities/setting.dart';
import '../../domain/repositories/setting.dart';

import '../utils/storage.dart';

class DataSettingRepository extends SettingRepository {
  @override
  Future<void> resetToDefaults() async {
    final storage = await Storage.load();

    storage.settings = [
      RemoteLoggingSetting(false),
    ];

    return null;
  }

  @override
  Future<List<Setting>> getSettings() async {
    return (await Storage.load()).settings;
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

    (await Storage.load()).settings = newSettings;
  }
}
