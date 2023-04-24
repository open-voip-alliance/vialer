// ignore_for_file: avoid_types_on_closure_parameters

import '../../../../dependency_locator.dart';
import '../../../calling/voip/user_voip_config_repository.dart';
import '../../user.dart';
import '../user_refresh_task_performer.dart';

class RefreshUserVoipConfig extends UserRefreshTaskPerformer {
  late final _userVoipConfigRepository =
      dependencyLocator<UserVoipConfigRepository>();

  @override
  Future<UserMutator> performUserRefreshTask(User user) async {
    final config = await _userVoipConfigRepository.get();

    return (User user) => user.copyWith(voip: () => config);
  }
}
