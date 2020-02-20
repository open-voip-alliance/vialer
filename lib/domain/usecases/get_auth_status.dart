import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../repositories/auth.dart';

class GetAuthStatusUseCase extends UseCase<bool, void> {
  final AuthRepository authRepository;

  GetAuthStatusUseCase(this.authRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(_) async {
    final controller = StreamController<bool>();

    controller.add(await authRepository.isAuthenticated());
    unawaited(controller.close());

    return controller.stream;
  }
}
