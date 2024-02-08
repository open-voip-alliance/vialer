import 'dart:async';

import '../../../../../data/repositories/metrics/metrics.dart';
import '../../../../../dependency_locator.dart';
import '../../../../data/models/business_availability/temporary_redirect/temporary_redirect.dart';
import '../../../../data/models/voicemail/voicemail_account.dart';
import '../../../../data/repositories/business_availability/business_availability_repository.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import 'get_current_temporary_redirect.dart';

class StartTemporaryRedirect extends UseCase
    with TemporaryRedirectEventBroadcaster {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();
  late final _metricsRepository = dependencyLocator<MetricsRepository>();

  Future<void> call({
    required VoicemailAccount voicemailAccount,
    required DateTime endingAt,
  }) async {
    await _businessAvailability.createTemporaryRedirect(
      user: _getUser(),
      temporaryRedirect: TemporaryRedirect(
        endsAt: endingAt,
        destination: TemporaryRedirectDestination.voicemail(voicemailAccount),
      ),
    );

    _metricsRepository.track(
      'temporary-redirect-started',
      {'ending-at': endingAt.toIso8601String()},
    );
    unawaited(broadcast());
  }
}
