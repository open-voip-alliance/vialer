import '../entities/setting.dart';

abstract class SettingRepository {
  Future<void> resetToDefaults();

  Future<List<Setting>> getSettings();

  Future<void> changeSetting(Setting setting);
}