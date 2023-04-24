// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../dependency_locator.dart';
import '../../../authentication/authentication_repository.dart';
import '../../../calling/voip/user_voip_config_repository.dart';
import '../../../voipgrid/user_voip_config.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshUserVoipConfig extends UserRefreshTaskPerformer {
  late final _userVoipConfigRepository =
      dependencyLocator<UserVoipConfigRepository>();
  late final _authRepository = dependencyLocator<AuthRepository>();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final config = await _userVoipConfigRepository.get();

    _ensureAppAccountIsConfiguredCorrectly(config);

    return (User user) => user.copyWith(voip: () => config);
  }

  void _ensureAppAccountIsConfiguredCorrectly(UserVoipConfig? config) {
    if (config == null) return;

    if (!config.useEncryption || !config.useOpus) {
      // These values are required for the app to function, so we always want to
      // make sure they are set to [true].
      _authRepository.updateAppAccount(
        useEncryption: true,
        useOpus: true,
      );
    }
  }
}
