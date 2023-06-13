import 'package:vialer/domain/user/refresh/user_refresh_task_performer.dart';

import '../../../../dependency_locator.dart';
import '../../../calling/voip/user_voip_config_repository.dart';
import '../../user.dart';

class RefreshUserWebphoneAccount extends UserRefreshTaskPerformer {
  const RefreshUserWebphoneAccount();

  UserVoipConfigRepository get _repository =>
      dependencyLocator<UserVoipConfigRepository>();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final webphoneAccountId = await _repository.getSelectedWebphoneAccountId();

    return (User user) =>
        user.copyWith(webphoneAccountId: () => webphoneAccountId,);
  }
}
