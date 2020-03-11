import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/setting.dart';
import '../repositories/setting.dart';
import '../repositories/logging.dart';

class ChangeSettingUseCase extends UseCase<void, ChangeSettingUseCaseParams> {
  final SettingRepository _settingRepository;
  final LoggingRepository _loggingRepository;

  ChangeSettingUseCase(this._settingRepository, this._loggingRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(
    ChangeSettingUseCaseParams params,
  ) async {
    final controller = StreamController<void>();
    final setting = params.setting;

    await _settingRepository.changeSetting(setting);

    if (setting is RemoteLoggingSetting) {
      if (setting.value) {
        await _loggingRepository.enableRemoteLogging();
      } else {
        await _loggingRepository.disableRemoteLogging();
      }
    }

    unawaited(controller.close());

    return controller.stream;
  }
}

class ChangeSettingUseCaseParams {
  final Setting setting;

  ChangeSettingUseCaseParams(this.setting);
}
