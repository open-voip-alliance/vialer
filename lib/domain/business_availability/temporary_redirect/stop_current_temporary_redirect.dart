import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../business_availability_repository.dart';
import 'get_current_temporary_redirect.dart';

class StopCurrentTemporaryRedirect extends UseCase
    with TemporaryRedirectEventBroadcaster {
  late final _getCurrentRedirect = GetCurrentTemporaryRedirect();
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

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

    unawaited(track());
    unawaited(broadcast());
  }
}
