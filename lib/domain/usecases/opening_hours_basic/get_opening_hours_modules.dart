import '../../../data/models/opening_hours_basic/opening_hours.dart';
import '../../../data/repositories/opening_hours_basic/opening_hours_repository.dart';
import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';

class GetOpeningHoursModules extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _openingHours = dependencyLocator<OpeningHoursRepository>();

  Future<List<OpeningHoursModule>> call() {
    final user = _getUser();

    return _openingHours.getModules(
      user: user,
    );
  }
}
