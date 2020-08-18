import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/onboarding/login.dart';
import '../../../../domain/usecases/reset_settings.dart';

class LoginPresenter extends Presenter {
  Function loginOnNext;
  Function loginOnError;

  final _login = LoginUseCase();
  final _resetSettings = ResetSettingsUseCase();

  void login(String email, String password) {
    _login(email: email, password: password).then(
      loginOnNext,
      onError: loginOnError,
    );
  }

  void resetSettingsToDefaults() => _resetSettings();

  @override
  void dispose() {}
}
