import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/setting.dart';
import '../repositories/setting.dart';

class ResetToDefaultSettingsUseCase extends UseCase<void, void> {
  final SettingRepository settingRepository;

  ResetToDefaultSettingsUseCase(this.settingRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Setting>>();

    await settingRepository.resetToDefaults();
    unawaited(controller.close());

    return controller.stream;
  }
}