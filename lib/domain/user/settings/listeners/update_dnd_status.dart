import 'dart:async';

import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../calling/dnd/dnd_repository.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateDndStatus extends SettingChangeListener<bool> with Loggable {
  DndRepository get _repository => dependencyLocator<DndRepository>();

  @override
  final key = CallSetting.dnd;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    bool value,
  ) async {
    await _repository.changeDndStatus(
      GetLoggedInUserUseCase()(),
      DndStatus.fromBool(value),
    );

    return successResult;
  }
}
