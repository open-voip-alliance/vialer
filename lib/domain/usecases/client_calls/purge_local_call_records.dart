import '../../../app/util/loggable.dart';
import '../../../dependency_locator.dart';
import '../../repositories/local_client_calls.dart';
import '../../repositories/metrics.dart';
import '../../use_case.dart';

class PurgeLocalCallRecords extends UseCase with Loggable {
  final _clientCallsRepository =
      dependencyLocator<LocalClientCallsRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  /// We store client calls in a local database, for security reasons these
  /// must be completed removed if a user were to logout or no longer have
  /// appropriate permissions.
  Future<void> call({
    required PurgeReason reason,
  }) async {
    logger.info(
      'Deleting all locally stored client calls due to ${reason.name}',
    );

    final amountDeleted = await _clientCallsRepository.deleteAll();

    logger.info('Removed $amountDeleted local client calls.');

    _metricsRepository.track('client-calls-purged', {
      'amount': amountDeleted,
      'reason': reason,
    });
  }
}

enum PurgeReason {
  permissionFailed,
  logout,
  unauthorized,
  disabled,
}
