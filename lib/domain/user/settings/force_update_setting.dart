import 'package:vialer/domain/use_case.dart';
import 'package:vialer/domain/user/settings/settings.dart';
import 'package:vialer/domain/user/settings/settings_repository.dart';

import '../../../dependency_locator.dart';

/// Forces an update of a local setting. This will NOT apply any side-effects
/// (such as updating the server) and therefore should ONLY be used in
/// specific situations where you know this is the correct option.
///
/// For example, this can be used when initializing a user to make sure these
/// values are pre-configured without updating the server.
///
/// In (almost) all situations, refer to [ChangeSetting] instead.
class ForceUpdateSetting extends UseCase {
  final _settingsRepository = dependencyLocator.get<SettingsRepository>();

  Future<void> call<T extends Object>(
    SettingKey<T> key,
    T value,
  ) async =>
      _settingsRepository.change(key, value);
}
