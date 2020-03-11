abstract class LoggingRepository {
  Future<void> enableConsoleLogging();

  Future<void> enableRemoteLoggingIfSettingEnabled();

  Future<void> enableRemoteLogging();

  Future<void> disableRemoteLogging();
}
