import '../entities/setting.dart';
import '../use_case.dart';
import 'enable_remote_logging.dart';
import 'get_settings.dart';

class EnableRemoteLoggingIfNeededUseCase extends FutureUseCase<void> {
  // TODO: Use GetSettingUseCase (singular)
  final _getSettings = GetSettingsUseCase();
  final _enableRemoteLogging = EnableRemoteLoggingUseCase();

  @override
  Future<void> call() async {
    final settings = await _getSettings();
    final setting = settings.get<RemoteLoggingSetting>();

    if (setting?.value == true) {
      await _enableRemoteLogging();
    }
  }
}
