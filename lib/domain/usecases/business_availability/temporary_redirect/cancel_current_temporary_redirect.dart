import 'dart:async';

import '../../../../../dependency_locator.dart';
import '../../../../data/repositories/business_availability/business_availability_repository.dart';
import '../../../../data/repositories/metrics/metrics.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import 'get_current_temporary_redirect.dart';

class CancelCurrentTemporaryRedirect extends UseCase
    with TemporaryRedirectEventBroadcaster {
  late final _getCurrentRedirect = GetCurrentTemporaryRedirect();
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call() async {
    final current = await _getCurrentRedirect();

    if (current == null) {
      logger.info(
        'Not stopping because there is no current temporary redirect',
      );
      return;
    }

    await _businessAvailability.cancelTemporaryRedirect(
      user: _getUser(),
      temporaryRedirect: current,
    );

    _metricsRepository.track('temporary-redirect-cancelled');
    unawaited(broadcast());
  }
}
