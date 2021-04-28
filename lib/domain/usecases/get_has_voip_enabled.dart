import '../entities/setting.dart';
import '../use_case.dart';
import 'get_is_voip_allowed.dart';
import 'get_setting.dart';

/// Whether the user can use VoIP _and_ has the VoIP setting enabled.
class GetHasVoipEnabledUseCase extends UseCase {
  final _getUseVoipSetting = GetSettingUseCase<UseVoipSetting>();
  final _getIsVoipAllowed = GetIsVoipAllowed();

  Future<bool> call() async =>
      await _getIsVoipAllowed() && (await _getUseVoipSetting()).value;
}
