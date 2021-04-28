import '../entities/setting.dart';
import '../use_case.dart';
import 'enable_remote_logging.dart';
import 'get_setting.dart';

class EnableRemoteLoggingIfNeededUseCase extends UseCase {
  final _getSetting = GetSettingUseCase<RemoteLoggingSetting>();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();

  Future<void> call() async {
    final setting = await _getSetting();

    if (setting.value == true) {
      await _enableRemoteLogging();
    }
  }
}
