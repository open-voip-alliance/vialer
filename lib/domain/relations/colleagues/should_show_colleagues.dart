import '../../../app/util/loggable.dart';
import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../voipgrid/user_permissions.dart';

class ShouldShowColleagues extends UseCase with Loggable {
  late final _getUser = GetLoggedInUserUseCase();

  bool call() {
    try {
      return _getUser().hasPermission(Permission.canViewColleagues);
    } on TypeError catch (_) {
      return false;
    }
  }
}
