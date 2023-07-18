import 'dart:async';

import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/dnd/dnd_repository.dart';
import '../../../calling/voip/register_to_voip_middleware.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateDndStatus extends SettingChangeListener<bool> with Loggable {
  final _registerToVoipMiddleware = RegisterToVoipMiddlewareUseCase();

  DndRepository get _repository => dependencyLocator<DndRepository>();

  @override
  final key = CallSetting.dnd;

  bool get hasUserBasedDnd => HasFeature()(Feature.userBasedDnd);

  @override
  FutureOr<SettingChangeListenResult> preStore(User user, bool value) async {
    if (hasUserBasedDnd) {
      await _repository.changeDndStatus(
        GetLoggedInUserUseCase()(),
        DndStatus.fromBool(value),
      );
    }
    return successResult;
  }

  @override
  FutureOr<SettingChangeListenResult> postStore(
    User user,
    bool value,
  ) async {
    if (!hasUserBasedDnd) {
      // The correct value for DND will be automatically submitted when refreshing
      // our registration.
      await _registerToVoipMiddleware();
    }

    return successResult;
  }
}
