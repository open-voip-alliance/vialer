import 'dart:async';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../data/repositories/call_records/client/local_client_calls.dart';
import '../../../../dependency_locator.dart';
import '../../../../presentation/util/loggable.dart';
import '../../use_case.dart';

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
