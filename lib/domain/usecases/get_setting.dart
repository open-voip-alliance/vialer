import 'dart:async';

import '../entities/setting.dart';
import '../use_case.dart';
import 'get_settings.dart';

class GetSettingUseCase<S extends Setting> extends FutureUseCase<S> {
  final _getSettings = GetSettingsUseCase();

  @override
  Future<S> call() => _getSettings().then(
        (settings) => settings.get<S>(),
      );
}
