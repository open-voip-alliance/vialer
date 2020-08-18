import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/change_password.dart';

import '../../../../domain/repositories/auth.dart';
import '../../../../domain/repositories/setting.dart';
import '../../../../domain/repositories/logging.dart';

class PasswordPresenter extends Presenter {
  Function changePaswordOnComplete;
  Function changePasswordOnError;

  Function loginOnComplete;

  final ChangePasswordUseCase _changePassword;

  PasswordPresenter(
    AuthRepository authRepository,
    SettingRepository settingRepository,
    LoggingRepository loggingRepository,
  ) : _changePassword = ChangePasswordUseCase(authRepository);

  void changePassword(String password) {
    _changePassword(
      newPassword: password,
    ).then(
      (_) => changePaswordOnComplete(),
      onError: changePasswordOnError,
    );
  }

  @override
  void dispose() {}
}
