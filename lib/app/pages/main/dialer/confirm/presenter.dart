import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/setting.dart';

import '../../../../../domain/usecases/call.dart';
import '../../../../../domain/usecases/change_setting.dart';
import '../../../../../domain/usecases/get_outgoing_cli.dart';
import '../../../../../domain/usecases/get_settings.dart';

class ConfirmPresenter extends Presenter {
  Function callOnComplete;
  Function callOnError;

  Function settingsOnNext;

  Function outgoingCliOnNext;

  final _call = CallUseCase();
  final _getSettings = GetSettingsUseCase();
  final _changeSetting = ChangeSettingUseCase();
  final _getOutgoingCli = GetOutgoingCliUseCase();

  void call(String destination) => _call(destination: destination).then(
        (_) => callOnComplete(),
        onError: callOnError,
      );

  void getOutgoingCli() => outgoingCliOnNext(_getOutgoingCli());

  void getSettings() => _getSettings().then(settingsOnNext);

  @override
  void dispose() {}

  // ignore: avoid_positional_boolean_parameters
  void setShowDialogSetting(bool value) {
    _changeSetting(
      setting: ShowDialerConfirmPopupSetting(value),
    );
  }
}
