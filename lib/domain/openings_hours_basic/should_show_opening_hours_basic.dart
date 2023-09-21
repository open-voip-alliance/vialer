import '../use_case.dart';
import '../user/get_logged_in_user.dart';
import '../voipgrid/user_permissions.dart';

class ShouldShowOpeningHoursBasic extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();

  bool call() => _getUser().hasPermission(Permission.canChangeOpeningHours);
}
