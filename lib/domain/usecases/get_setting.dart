import 'dart:async';

import '../entities/setting.dart';
import '../use_case.dart';
import 'get_settings.dart';

class GetSettingUseCase<S extends Setting> extends UseCase {
  final _getSettings = GetSettingsUseCase();

  Future<S> call() => _getSettings().then((settings) => settings.get<S>());
}
