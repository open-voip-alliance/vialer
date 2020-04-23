import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/setting.dart';

import '../repositories/setting.dart';
import '../repositories/logging.dart';

class ResetToDefaultSettingsUseCase extends UseCase<void, void> {
  final SettingRepository settingRepository;
  final LoggingRepository loggingRepository;

  ResetToDefaultSettingsUseCase(this.settingRepository, this.loggingRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Setting>>();

    await settingRepository.resetToDefaults();
    await loggingRepository.enableRemoteLoggingIfSettingEnabled();
    unawaited(controller.close());

    return controller.stream;
  }
}
