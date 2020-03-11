import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../entities/system_user.dart';
import '../repositories/auth.dart';

class GetCurrentUserUseCase extends UseCase<SystemUser, void> {
  final AuthRepository authRepository;

  GetCurrentUserUseCase(this.authRepository);

  @override
  Future<Stream<SystemUser>> buildUseCaseStream(_) async {
    final controller = StreamController<SystemUser>();

    controller.add(authRepository.currentUser);
    unawaited(controller.close());

    return controller.stream;
  }
}
