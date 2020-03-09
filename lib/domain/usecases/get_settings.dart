import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/setting.dart';
import '../repositories/setting.dart';

class GetSettingsUseCase extends UseCase<List<Setting>, void> {
  final SettingRepository settingRepository;

  GetSettingsUseCase(this.settingRepository);

  @override
  Future<Stream<List<Setting>>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Setting>>();

    controller.add(await settingRepository.getSettings());
    unawaited(controller.close());

    return controller.stream;
  }
}
