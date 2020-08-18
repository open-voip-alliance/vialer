import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../domain/usecases/change_password.dart';

class PasswordPresenter extends Presenter {
  Function changePaswordOnComplete;
  Function changePasswordOnError;

  Function loginOnComplete;

  final _changePassword = ChangePasswordUseCase();

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
