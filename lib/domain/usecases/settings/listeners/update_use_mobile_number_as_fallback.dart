import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../entities/settings/call_setting.dart';
import '../../../entities/user.dart';
import '../../../repositories/auth.dart';
import 'setting_change_listener.dart';

class UpdateUseMobileNumberAsFallbackListener
    extends SettingChangeListener<bool> with Loggable {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  final key = CallSetting.useMobileNumberAsFallback;

  @override
  FutureOr<SettingChangeListenResult> beforeStore(
    User user,
    bool enabled,
  ) =>
      changeRemoteValue(
        () => _authRepository.setUseMobileNumberAsFallback(
          user,
          enable: enabled,
        ),
      );
}
