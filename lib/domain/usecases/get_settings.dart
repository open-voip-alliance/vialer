import 'dart:async';

import '../../dependency_locator.dart';
import '../entities/setting.dart';
import '../repositories/setting.dart';
import '../use_case.dart';

class GetSettingsUseCase extends FutureUseCase<List<Setting>> {
  final _settingRepository = dependencyLocator<SettingRepository>();

  @override
  Future<List<Setting>> call() => _settingRepository.getSettings();
}
