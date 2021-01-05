import '../../domain/entities/setting.dart';
import '../../domain/repositories/storage.dart';
import 'auth.dart';

class SettingRepository {
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;

  SettingRepository(this._storageRepository, this._authRepository);

  Future<List<Setting>> getSettings() async {
    final storedSettings = _storageRepository.settings;

    return [
      ...storedSettings,
      // Add presets for which no stored setting is found.
      ...Setting.presets.where(
        (s) => !storedSettings.any(
          (stored) => stored.runtimeType == s.runtimeType,
        ),
      ),
      PhoneNumberSetting(
        _authRepository.currentUser?.outgoingCli,
      ),
    ];
  }

  Future<void> changeSetting(Setting setting) async {
    if (!setting.mutable) {
      throw UnsupportedError(
        'Vialer error: Unsupported operation: '
        'Don\'t save an immutable setting.',
      );
    }

    final settings = await getSettings();

    final newSettings = List<Setting>.from(settings)
      ..removeWhere((e) => e.runtimeType == setting.runtimeType)
      ..add(setting);

    // We only want to save mutable settings.
    _storageRepository.settings = newSettings.where((s) => s.mutable).toList();
  }
}
