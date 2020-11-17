import 'auth.dart';

import '../../domain/entities/setting.dart';

import '../../domain/repositories/storage.dart';

class SettingRepository {
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;

  SettingRepository(this._storageRepository, this._authRepository);

  Future<List<Setting>> getSettings() async {
    final storedSettings = _storageRepository.settings;

    return [
      ...storedSettings,
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

    if (setting.external) {
      throw UnsupportedError(
        'Vialer error: Unsupported operation: '
        'Don\'t save an external setting.',
      );
    }

    final settings = await getSettings();

    final newSettings = List<Setting>.from(settings)
      ..removeWhere((e) => e.runtimeType == setting.runtimeType)
      ..add(setting);

    // We only want to save mutable and non-external settings.
    _storageRepository.settings =
        newSettings.where((s) => s.mutable && !s.external).toList();
  }
}
