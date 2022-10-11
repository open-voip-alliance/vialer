import 'package:dartx/dartx.dart';

import '../../../dependency_locator.dart';
import '../../entities/temporary_redirect.dart';
import '../../entities/voicemail.dart';
import '../../repositories/business_availability_repository.dart';
import '../../use_case.dart';
import '../get_logged_in_user.dart';

class SetupTemporaryRedirect extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

  Future<void> call({
    required VoicemailAccount voicemailAccount,
  }) async {
    final endingAt = _endingAt;

    _businessAvailability.createCurrentTemporaryRedirect(
      user: _getUser(),
      temporaryRedirect: TemporaryRedirect(
        endsAt: endingAt,
        destination: TemporaryRedirectDestination.voicemail(voicemailAccount),
      ),
    );

    track({
      'ending-at': _endingAt.toIso8601String(),
    });
  }

  DateTime get _endingAt =>
      DateTime.now().copyWith(hour: 23, minute: 59, second: 59).toUtc();
}
