import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/setting.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/usecases/get_settings.dart';
import '../../../../domain/usecases/change_setting.dart';

class SettingsPresenter extends Presenter {
  Function settingsOnNext;
  Function changeSettingsOnNext;

  final GetSettingsUseCase _getSettingsUseCase;
  final ChangeSettingUseCase _changeSettingUseCase;

  SettingsPresenter(SettingRepository settingRepository)
      : _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _changeSettingUseCase = ChangeSettingUseCase(settingRepository);

  void getSettings() {
    _getSettingsUseCase.execute(_GetSettingsUseCaseObserver(this));
  }

  void changeSetting(Setting setting) {
    _changeSettingUseCase.execute(
      _ChangeSettingUseCaseObserver(this),
      ChangeSettingUseCaseParams(setting),
    );
  }

  @override
  void dispose() {
    _getSettingsUseCase.dispose();
  }
}

class _GetSettingsUseCaseObserver extends Observer<List<Setting>> {
  final SettingsPresenter presenter;

  _GetSettingsUseCaseObserver(this.presenter);

  @override
  void onComplete() {}

  @override
  void onError(dynamic e) {}

  @override
  void onNext(List<Setting> settings) => presenter.settingsOnNext(settings);
}

class _ChangeSettingUseCaseObserver extends Observer<void> {
  final SettingsPresenter presenter;

  _ChangeSettingUseCaseObserver(this.presenter);

  @override
  void onComplete() => presenter.changeSettingsOnNext();

  @override
  void onError(dynamic e) {}

  @override
  void onNext(_) => presenter.changeSettingsOnNext();
}
