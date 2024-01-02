import 'dart:async';

import 'package:vialer/domain/user/get_logged_in_user.dart';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../../relations/availability/availability_status_repository.dart';
import '../../../relations/user_availability_status.dart';
import '../../../user/user.dart';
import '../call_setting.dart';
import 'setting_change_listener.dart';

class UpdateAvailabilityStatus
    extends SettingChangeListener<UserAvailabilityStatus> with Loggable {
  UserAvailabilityStatusRepository get _repository =>
      dependencyLocator<UserAvailabilityStatusRepository>();

  @override
  final key = CallSetting.availabilityStatus;

  @override
  FutureOr<SettingChangeListenResult> applySettingsSideEffects(
    User user,
    UserAvailabilityStatus value,
  ) =>
      _repository
          .changeStatus(GetLoggedInUserUseCase()(), value)
          .then((result) => result.asSettingChangeListenResult());
}
