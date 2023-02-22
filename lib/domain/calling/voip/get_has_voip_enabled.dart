import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/settings/call_setting.dart';
import '../../voipgrid/user_voip_config.dart';

/// Whether the user can use VoIP _and_ has the VoIP setting enabled.
class GetHasVoipEnabledUseCase extends UseCase {
  final _getUser = GetLoggedInUserUseCase();

  bool call() {
    final user = _getUser();
    return user.voip.isAllowedCalling && user.settings.get(CallSetting.useVoip);
  }
}
