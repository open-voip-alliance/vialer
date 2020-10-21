import 'auth.dart';

import '../../domain/entities/setting.dart';

import '../../domain/repositories/storage.dart';

class SettingRepository {
  final StorageRepository _storageRepository;
  final AuthRepository _authRepository;

  SettingRepository(this._storageRepository, this._authRepository);

  Future<List<Setting>> getSettings() async {
    final phoneNumberSetting =
        PhoneNumberSetting(_authRepository.currentUser?.outgoingCli);

    if (!_storageRepository.settings.contains(phoneNumberSetting)) {
      return [
        ..._storageRepository.settings,
        phoneNumberSetting,
      ];
    } else {
      return _storageRepository.settings;
    }
  }

  Future<void> changeSetting(Setting setting) async {
    if (!setting.mutable) {
      throw UnsupportedError('Vialer error, unsupported operation: '
          'don\'t save an immutable setting.');
    }

    final settings = await getSettings();

    final newSettings = List<Setting>.from(settings)
      ..removeWhere((e) => e.runtimeType == setting.runtimeType)
      ..add(setting);

    _storageRepository.settings = newSettings;
  }
}
