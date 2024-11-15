import 'package:vialer/data/models/user/settings/app_setting.dart';
import 'package:vialer/domain/usecases/use_case.dart';
import 'package:vialer/domain/usecases/user/settings/change_setting.dart';

class DisableAdvancedVoipLogging extends UseCase {
  Future<void> call() => ChangeSettingUseCase()(
    AppSetting.enableAdvancedVoipLogging,
    false,
    track: false,
  );
}