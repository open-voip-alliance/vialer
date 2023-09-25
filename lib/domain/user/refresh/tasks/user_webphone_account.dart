import 'package:vialer/domain/user/refresh/user_refresh_task_performer.dart';

import '../../../../dependency_locator.dart';
import '../../../calling/voip/app_account_repository.dart';
import '../../user.dart';

class RefreshUserWebphoneAccount extends UserRefreshTaskPerformer {
  const RefreshUserWebphoneAccount();

  AppAccountRepository get _repository =>
      dependencyLocator<AppAccountRepository>();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final webphoneAccountId = await _repository.getSelectedWebphoneAccountId();

    return (User user) => user.copyWith(
          webphoneAccountId: () => webphoneAccountId,
        );
  }
}
