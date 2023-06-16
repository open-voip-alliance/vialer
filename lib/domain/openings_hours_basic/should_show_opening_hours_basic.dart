import '../use_case.dart';
import '../user/get_logged_in_user.dart';

class ShouldShowOpeningHoursBasic extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();

  bool call() => _getUser().permissions.canChangeOpeningHours;
}
