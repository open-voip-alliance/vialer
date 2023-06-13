// ignore_for_file: avoid_types_on_closure_parameters

import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../../authentication/authentication_repository.dart';
import '../../../calling/voip/user_voip_config_repository.dart';
import '../../../voipgrid/user_voip_config.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshUserVoipConfig extends UserRefreshTaskPerformer {
  const RefreshUserVoipConfig();

  UserVoipConfigRepository get _repository =>
      dependencyLocator<UserVoipConfigRepository>();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final config = await _repository.get();

    _ensureAppAccountIsConfiguredCorrectly(config);

    return (User user) => user.copyWith(voip: () => config);
  }

  void _ensureAppAccountIsConfiguredCorrectly(UserVoipConfig? config) {
    if (config == null) return;

    if (!config.useEncryption || !config.useOpus) {
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
