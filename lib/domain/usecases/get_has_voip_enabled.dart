import '../entities/setting.dart';
import '../use_case.dart';
import 'get_is_voip_allowed.dart';
import 'get_setting.dart';
import 'get_voip_config.dart';

/// Whether the user can use VoIP _and_ has the VoIP setting enabled.
class GetHasVoipEnabledUseCase extends UseCase {
  final _getUseVoipSetting = GetSettingUseCase<UseVoipSetting>();
  final _getIsVoipAllowed = GetIsVoipAllowedUseCase();
  final _getVoipConfig = GetVoipConfigUseCase();

  Future<bool> call() async =>
      await _getIsVoipAllowed() &&
      (await _getVoipConfig(latest: false)).isNotEmpty &&
      (await _getUseVoipSetting()).value;
}
