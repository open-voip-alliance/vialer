import '../../../dependency_locator.dart';
import '../../entities/temporary_redirect.dart';
import '../../repositories/business_availability_repository.dart';
import '../../use_case.dart';
import '../get_logged_in_user.dart';

class GetCurrentTemporaryRedirectUseCase extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _businessAvailability =
      dependencyLocator<BusinessAvailabilityRepository>();

  Future<TemporaryRedirect?> call() =>
      _businessAvailability.getCurrentTemporaryRedirect(user: _getUser());
}
