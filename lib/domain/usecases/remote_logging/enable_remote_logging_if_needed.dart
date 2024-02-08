import 'package:vialer/data/models/user/settings/app_setting.dart';

import '../../../data/models/user/user.dart';
import '../use_case.dart';
import '../user/get_stored_user.dart';
import 'enable_remote_logging.dart';

class EnableRemoteLoggingIfNeededUseCase extends UseCase {
  final _getUser = GetStoredUserUseCase();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();

  Future<void> call() async {
    final enabled = _getUser()?.settings.get(AppSetting.remoteLogging) ?? false;

    if (enabled) {
      await _enableRemoteLogging();
    }
  }
}
