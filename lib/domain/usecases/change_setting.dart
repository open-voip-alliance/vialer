import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/setting.dart';
import '../repositories/setting.dart';

class ChangeSettingUseCase extends UseCase<void, ChangeSettingUseCaseParams> {
  final SettingRepository settingRepository;

  ChangeSettingUseCase(this.settingRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(
    ChangeSettingUseCaseParams params,
  ) async {
    final controller = StreamController<void>();

    await settingRepository.changeSetting(params.setting);
    unawaited(controller.close());

    return controller.stream;
  }
}

class ChangeSettingUseCaseParams {
  final Setting setting;

  ChangeSettingUseCaseParams(this.setting);
}
