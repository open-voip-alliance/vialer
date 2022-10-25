import 'package:dartx/dartx.dart';

import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../voicemail/voicemail_account.dart';
import '../business_availability_repository.dart';
import 'get_current_temporary_redirect.dart';
import 'temporary_redirect.dart';

class StartTemporaryRedirect extends UseCase with TemporaryRedirectEvents {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

  Future<void> call({
    required VoicemailAccount voicemailAccount,
  }) async {
    final endingAt = _endingAt;

    await _businessAvailability.createTemporaryRedirect(
      user: _getUser(),
      temporaryRedirect: TemporaryRedirect(
        endsAt: endingAt,
        destination: TemporaryRedirectDestination.voicemail(voicemailAccount),
      ),
    );

    track({'ending-at': _endingAt.toIso8601String()});
    broadcast();
  }

  DateTime get _endingAt =>
      DateTime.now().copyWith(hour: 23, minute: 59, second: 59).toUtc();
}
