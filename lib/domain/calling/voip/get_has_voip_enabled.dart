import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/settings/call_setting.dart';

class GetHasVoipEnabledUseCase extends UseCase {
  final _getUser = GetLoggedInUserUseCase();

  bool call() => _getUser().settings.get(CallSetting.useVoip);
}
