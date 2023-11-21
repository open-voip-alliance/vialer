import 'package:vialer/domain/user/refresh/user_refresh_task_performer.dart';
import 'package:vialer/domain/user/settings/call_setting.dart';

import '../../../../dependency_locator.dart';
import '../../../relations/availability/availability_status_repository.dart';
import '../../user.dart';

class RefreshUserAvailabilityStatus extends SettingsRefreshTaskPerformer {
  const RefreshUserAvailabilityStatus();

  UserAvailabilityStatusRepository get _repository =>
      dependencyLocator<UserAvailabilityStatusRepository>();

  @override
  Future<SettingsMutator> performSettingsRefreshTask(User user) async {
    try {
      final status = await _repository.getStatus(user);

      return (User user) => (CallSetting.availabilityStatus, status);
    } catch (e) {
      return null;
    }
  }
}
