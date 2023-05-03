import '../../app/util/loggable.dart';
import '../../dependency_locator.dart';
import '../calling/voip/start_voip.dart';
import '../calling/voip/stop_voip.dart';
import '../calling/voip/unregister_to_voip_middleware.dart';
import '../metrics/metrics.dart';
import '../use_case.dart';
import '../voipgrid/user_voip_config.dart';

class HandleUserVoipConfigChange extends UseCase with Loggable {
  late final metrics = dependencyLocator<MetricsRepository>();
  late final _stopVoip = StopVoipUseCase();
  late final _startVoip = StartVoipUseCase();
  late final _unregisterFromMiddleware = UnregisterToVoipMiddlewareUseCase();

  Future<void> call({
    required UserVoipConfig? previous,
    required UserVoipConfig? current,
  }) async {
    if (previous == current) return;

    if (previous == null && current != null) {
      await _handleAppAccountAdded(current);
    } else if (previous != null && current == null) {
      await _handleAppAccountRemoved(previous);
    } else if (previous != null && current != null) {
      await _handleAppAccountChanged(previous, current);
    }
  }

  Future<void> _handleAppAccountAdded(UserVoipConfig current) {
    logger.info(
      'App account [${current.sipUserId}] has been added to this user and they '
      'will now be able to make calls',
    );
    metrics.track('app-account-added');
    return _startVoip();
  }

  Future<void> _handleAppAccountRemoved(UserVoipConfig previous) {
    logger.info(
      'App account [${previous.sipUserId}] has been removed from this user and '
      'they will no longer be able to make calls',
    );
    metrics.track('app-account-removed');
    return _stopVoipAndUnregister(appAccount: previous);
  }

  Future<void> _handleAppAccountChanged(
    UserVoipConfig previous,
    UserVoipConfig current,
  ) async {
    // We don't care if only basic parameters have been changed for the app
    // account (such as codecs) as the app will fix these automatically.
    if (!current.haveVoipCredentialsChanged(previous)) {
      return;
    }

    if (previous.sipUserId != current.sipUserId) {
      logger.info(
        'App account has been changed from '
        '[${previous.sipUserId}] to [${current.sipUserId}]',
      );
      metrics.track('app-account-changed');
    } else {
      logger.info('App account password has been changed');
      metrics.track('app-account-password-changed');
    }

    await _stopVoipAndUnregister(appAccount: previous);
    return _startVoip();
  }

  /// Stops voip and then unregisters with a specific [appAccount], this means
  /// that we can ensure the previous, removed app account is fully unregistered
  /// and will no longer receive calls.
  Future<void> _stopVoipAndUnregister({
    required UserVoipConfig appAccount,
  }) async {
    await _stopVoip();
    return _unregisterFromMiddleware(userVoipConfig: appAccount);
  }
}

extension on UserVoipConfig {
  bool haveVoipCredentialsChanged(UserVoipConfig other) =>
      sipUserId != other.sipUserId || password != other.password;
}
