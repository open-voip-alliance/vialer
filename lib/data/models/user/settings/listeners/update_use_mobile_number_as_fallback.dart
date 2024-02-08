import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../../presentation/util/loggable.dart';
import '../../../../repositories/authentication/authentication_repository.dart';
import '../../user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateUseMobileNumberAsFallbackListener
    extends SettingChangeListener<bool> with Loggable {
  final _authRepository = dependencyLocator<AuthRepository>();

  @override
  final key = CallSetting.useMobileNumberAsFallback;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    bool value,
  ) =>
      changeRemoteValue(
        () => _authRepository.setUseMobileNumberAsFallback(
          user,
          enable: value,
        ),
      );
}
