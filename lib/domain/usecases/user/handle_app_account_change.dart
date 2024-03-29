import '../../../data/models/voipgrid/app_account.dart';
import '../../../data/repositories/metrics/metrics.dart';
import '../../../dependency_locator.dart';
import '../../../presentation/util/loggable.dart';
import '../calling/voip/start_voip.dart';
import '../calling/voip/stop_voip.dart';
import '../calling/voip/unregister_to_middleware.dart';
import '../use_case.dart';

class HandleAppAccountChange extends UseCase with Loggable {
  late final _metrics = dependencyLocator<MetricsRepository>();
  late final _stopVoip = StopVoipUseCase();
  late final _startVoip = StartVoipUseCase();
  late final _unregisterFromMiddleware = UnregisterToMiddlewareUseCase();

  Future<void> call({
    required AppAccount? previous,
    required AppAccount? current,
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

  Future<void> _handleAppAccountAdded(AppAccount current) {
    logger.info(
      'App account [${current.sipUserId}] has been added to this user and they '
      'will now be able to make calls',
    );
    _metrics.track('app-account-added');
    return _startVoip();
  }

  Future<void> _handleAppAccountRemoved(AppAccount previous) {
    logger.info(
      'App account [${previous.sipUserId}] has been removed from this user and '
      'they will no longer be able to make calls',
    );
    _metrics.track('app-account-removed');
    return _stopVoipAndUnregister(appAccount: previous);
  }

  Future<void> _handleAppAccountChanged(
    AppAccount previous,
    AppAccount current,
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
      _metrics.track('app-account-changed');
    } else {
      logger.info('App account password has been changed');
      _metrics.track('app-account-password-changed');
    }

    await _stopVoipAndUnregister(appAccount: previous);
    return _startVoip();
  }

  /// Stops voip and then unregisters with a specific [appAccount], this means
  /// that we can ensure the previous, removed app account is fully unregistered
  /// and will no longer receive calls.
  Future<void> _stopVoipAndUnregister({
    required AppAccount appAccount,
  }) async {
    await _stopVoip();
    return _unregisterFromMiddleware(appAccount: appAccount);
  }
}

extension on AppAccount {
  bool haveVoipCredentialsChanged(AppAccount other) =>
      sipUserId != other.sipUserId || password != other.password;
}
