import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/usecases/onboarding/request_permission.dart';

class PermissionPresenter extends Presenter {
  Function requestPermissionOnNext;

  final _requestPermission = RequestPermissionUseCase();

  void ask(Permission permission) =>
      _requestPermission(permission: permission).then(requestPermissionOnNext);

  @override
  void dispose() {}
}
