import '../../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../business_availability_repository.dart';
import 'get_current_temporary_redirect.dart';
import 'temporary_redirect.dart';
import 'temporary_redirect_exception.dart';

class ChangeCurrentTemporaryRedirect extends UseCase
    with TemporaryRedirectEvents {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

  Future<void> call({
    required TemporaryRedirect temporaryRedirect,
  }) async {
    try {
      await _businessAvailability.updateTemporaryRedirect(
        user: _getUser(),
        temporaryRedirect: temporaryRedirect,
      );
    } on NoTemporaryRedirectSetupException catch (e) {
      logger.info(
        'Unable to change current temporary redirect: $e',
      );
      return;
    }

    track({
      'ending-at': temporaryRedirect.endsAt,
      'id': temporaryRedirect.id,
    });

    broadcast();
  }
}
