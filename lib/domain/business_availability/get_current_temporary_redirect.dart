import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import 'business_availability_repository.dart';
import 'temporary_redirect.dart';

class GetCurrentTemporaryRedirectUseCase extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

  Future<TemporaryRedirect?> call() =>
      _businessAvailability.getCurrentTemporaryRedirect(user: _getUser());
}
