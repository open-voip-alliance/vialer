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

    final newSettings = List<Setting>.from(settings)
      ..removeWhere((e) => e.runtimeType == setting.runtimeType)
      ..add(setting);

    _storageRepository.settings = newSettings;
  }
}
