import 'dart:async';

import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../voicemail/voicemail_account.dart';
import '../business_availability_repository.dart';
import 'get_current_temporary_redirect.dart';
import 'temporary_redirect.dart';

class StartTemporaryRedirect extends UseCase
    with TemporaryRedirectEventBroadcaster {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

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

    track({'temporary-redirect-started': endingAt.toIso8601String()});
    unawaited(broadcast());
  }
}
