import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/entities/setting.dart';

import '../../../../domain/repositories/storage.dart';
import '../../../../domain/repositories/logging.dart';
import '../../../../domain/repositories/setting.dart';

import '../../../../domain/usecases/get_settings.dart';
import '../../../../domain/usecases/change_setting.dart';
import '../../../../domain/usecases/logout.dart';

import '../../../util/debug.dart';

class SettingsPresenter extends Presenter {
  Function settingsOnNext;
  Function changeSettingsOnNext;
  Function logoutOnComplete;

  final GetSettingsUseCase _getSettingsUseCase;
  final ChangeSettingUseCase _changeSettingUseCase;
  final LogoutUseCase _logoutUseCase;

  SettingsPresenter(
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
    StorageRepository storageRepository,
  )   : _getSettingsUseCase = GetSettingsUseCase(settingRepository),
        _changeSettingUseCase = ChangeSettingUseCase(
          settingRepository,
          loggingRepository,
        ),
        _logoutUseCase = LogoutUseCase(storageRepository);

  void getSettings() {
    _getSettingsUseCase.execute(_GetSettingsUseCaseObserver(this));
  }

  void changeSetting(Setting setting) {
    if (setting is RemoteLoggingSetting && !inDebugMode) {
      return;
    }

    _changeSettingUseCase.execute(
      _ChangeSettingUseCaseObserver(this),
      ChangeSettingUseCaseParams(setting),
    );
  }

  void logout() {
    _logoutUseCase.execute(_LogoutUseCaseObserver(this));
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

class _LogoutUseCaseObserver extends Observer<void> {
  final SettingsPresenter presenter;

  _LogoutUseCaseObserver(this.presenter);

  @override
  void onComplete() => presenter.logoutOnComplete();

  @override
  void onError(dynamic e) {}

  @override
  void onNext(_) => presenter.logoutOnComplete();
}
