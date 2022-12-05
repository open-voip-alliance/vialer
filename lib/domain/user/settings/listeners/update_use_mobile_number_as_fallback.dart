import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../authentication/authentication_repository.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateUseMobileNumberAsFallbackListener
    extends SettingChangeListener<bool> with Loggable {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  final key = CallSetting.useMobileNumberAsFallback;

  @override
  FutureOr<SettingChangeListenResult> preStore(
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
