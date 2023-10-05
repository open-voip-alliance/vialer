import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../../authentication/authentication_repository.dart';
import '../../../calling/voip/app_account_repository.dart';
import '../../../voipgrid/app_account.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshAppAccount extends UserRefreshTaskPerformer {
  const RefreshAppAccount();

  AppAccountRepository get _repository =>
      dependencyLocator<AppAccountRepository>();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final config = await _repository.get();

    _ensureAppAccountIsConfiguredCorrectly(config);

    return (User user) => user.copyWith(appAccount: () => config);
  }

  void _ensureAppAccountIsConfiguredCorrectly(AppAccount? appAccount) {
    if (appAccount == null) return;

    if (!appAccount.useEncryption || !appAccount.useOpus) {
      // These values are required for the app to function, so we always want to
      // make sure they are set to [true].
      unawaited(
        dependencyLocator<AuthRepository>().updateAppAccount(
          useEncryption: true,
          useOpus: true,
        ),
      );
    }
  }
}
