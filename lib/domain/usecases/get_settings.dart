import 'dart:async';

import '../entities/setting.dart';
import '../repositories/setting.dart';
import '../use_case.dart';

class GetSettingsUseCase extends FutureUseCase<List<Setting>> {
  final SettingRepository _settingRepository;

  GetSettingsUseCase(this._settingRepository);

  @override
  Future<List<Setting>> call() => _settingRepository.getSettings();
}
