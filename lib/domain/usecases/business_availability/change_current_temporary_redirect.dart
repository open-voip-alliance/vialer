import '../../../dependency_locator.dart';
import '../../entities/exceptions/temporary_redirect.dart';
import '../../entities/temporary_redirect.dart';
import '../../repositories/business_availability_repository.dart';
import '../../use_case.dart';
import '../get_logged_in_user.dart';

class ChangeCurrentTemporaryRedirectUseCase extends UseCase {
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
  }
}
