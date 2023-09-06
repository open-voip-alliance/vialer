import 'package:vialer/domain/calling/dnd/dnd_repository.dart';
import 'package:vialer/domain/feature/feature.dart';
import 'package:vialer/domain/feature/has_feature.dart';
import 'package:vialer/domain/user/refresh/user_refresh_task_performer.dart';
import 'package:vialer/domain/user/settings/call_setting.dart';

import '../../../../dependency_locator.dart';
import '../../user.dart';

class RefreshUserDndStatus extends SettingsRefreshTaskPerformer {
  const RefreshUserDndStatus();

  DndRepository get _repository => dependencyLocator<DndRepository>();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User user) async {
    if (!HasFeature()(Feature.userBasedDnd)) {
      return null;
    }

    try {
      final dndStatus = await _repository.getDndStatus(user);

      return (User user) => (CallSetting.dnd, dndStatus.asBool());
    } catch (e) {
      return null;
    }
  }
}
