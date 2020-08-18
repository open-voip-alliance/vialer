import 'dart:async';

import 'package:meta/meta.dart';

import '../entities/setting.dart';
import '../repositories/setting.dart';
import '../repositories/logging.dart';
import '../use_case.dart';

class ChangeSettingUseCase extends FutureUseCase<void> {
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  ChangeSettingUseCase(this._settingRepository, this._loggingRepository);

  @override
  Future<void> call({@required Setting setting}) async {
    await _settingRepository.changeSetting(setting);

    if (setting is RemoteLoggingSetting) {
      if (setting.value) {
        await _loggingRepository.enableRemoteLogging();
      } else {
        await _loggingRepository.disableRemoteLogging();
      }
    }
  }
}
