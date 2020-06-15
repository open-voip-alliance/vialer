import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/change_password.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

import '../../main/util/observer.dart';

class PasswordPresenter extends Presenter {
  Function changePaswordOnComplete;
  Function changePasswordOnError;

  Function loginOnComplete;

  final ChangePasswordUseCase _changePasswordUseCase;

  PasswordPresenter(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
  ) : _changePasswordUseCase = ChangePasswordUseCase(authRepository);

  void changePassword(String password) {
    _changePasswordUseCase.execute(
      Watcher(
        onError: changePasswordOnError,
        onComplete: changePaswordOnComplete,
      ),
      ChangePasswordUseCaseParams(newPassword: password),
    );
  }

  @override
  void dispose() {
    _changePasswordUseCase.dispose();
  }
}
