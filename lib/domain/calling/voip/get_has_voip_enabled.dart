import '../../use_case.dart';
import '../../user/get_logged_in_user.dart';
import '../../user/settings/call_setting.dart';
import 'get_is_voip_allowed.dart';
import 'get_voip_config.dart';

/// Whether the user can use VoIP _and_ has the VoIP setting enabled.
class GetHasVoipEnabledUseCase extends UseCase {
  final _getUser = GetLoggedInUserUseCase();
  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<bool> call() async =>
      await _getIsVoipAllowed() &&
      (await _getVoipConfig(latest: false)).isNotEmpty &&
      _getUser().settings.get(CallSetting.useVoip);
}
