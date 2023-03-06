import '../../dependency_locator.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import 'opening_hours.dart';
import 'opening_hours_repository.dart';

class GetOpeningHours extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();
  late final _openingHours = dependencyLocator<OpeningHoursRepository>();

  Future<List<OpeningHours>> call() async {
    final user = _getUser();

    return await _openingHours.getOpeningHours(
      user: user,
    );
  }
}
