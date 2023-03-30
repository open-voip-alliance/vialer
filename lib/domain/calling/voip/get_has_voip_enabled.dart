import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/settings/call_setting.dart';

/// Whether the user can use VoIP _and_ has the VoIP setting enabled.
class GetHasVoipEnabledUseCase extends UseCase {
  final _getUser = GetLoggedInUserUseCase();

  bool call() => _getUser().settings.get(CallSetting.useVoip);
}
