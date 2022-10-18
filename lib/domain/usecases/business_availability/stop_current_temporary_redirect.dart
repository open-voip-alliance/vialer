import '../../../dependency_locator.dart';
import '../../repositories/business_availability_repository.dart';
import '../../use_case.dart';
import '../get_logged_in_user.dart';
import 'get_current_temporary_redirect.dart';

class StopCurrentTemporaryRedirectUseCase extends UseCase {
  late final _getCurrentRedirect = GetCurrentTemporaryRedirectUseCase();
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

    track();
  }
}