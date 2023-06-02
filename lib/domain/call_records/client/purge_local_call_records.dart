import 'dart:async';

import '../../../../app/util/loggable.dart';
import '../../../../dependency_locator.dart';
import '../../metrics/metrics.dart';
import '../../use_case.dart';
import 'local_client_calls.dart';

class PurgeLocalCallRecordsUseCase extends UseCase with Loggable {
  final _clientCallsRepository =
      dependencyLocator<LocalClientCallsRepository>();
  final _metricsRepository = dependencyLocator<MetricsRepository>();

  /// We store client calls in a local database, for security reasons these
  /// must be completed removed if a user were to logout or no longer have
  /// appropriate permissions.
  Future<void> call({
    required PurgeReason reason,
  }) async {
    final amountDeleted = await _clientCallsRepository.deleteAll();

    if (amountDeleted <= 0) return;

    logger.info(
      'Removed $amountDeleted local client calls because ${reason.name}',
    );

    _metricsRepository.track('client-calls-purged', <String, dynamic>{
      'amount': amountDeleted,
      'reason': reason.name,
    });
  }
}

enum PurgeReason {
  permissionFailed,
  logout,
  disabled,
}
