import 'dart:async';

import 'package:meta/meta.dart';

import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/setting.dart';
import '../repositories/logging.dart';
import '../use_case.dart';

class ChangeSettingUseCase extends FutureUseCase<void> {
  final _settingRepository = dependencyLocator<SettingRepository>();
  final _loggingRepository = dependencyLocator<LoggingRepository>();

  ChangeSettingUseCase();

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
