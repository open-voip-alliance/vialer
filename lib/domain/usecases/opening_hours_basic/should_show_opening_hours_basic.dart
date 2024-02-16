import '../../../../../data/repositories/voipgrid/user_permissions.dart';
import '../use_case.dart';
import '../user/get_logged_in_user.dart';

class ShouldShowOpeningHoursBasic extends UseCase {
  late final _getUser = GetLoggedInUserUseCase();

  bool call() => _getUser().hasPermission(Permission.canChangeOpeningHours);
}
