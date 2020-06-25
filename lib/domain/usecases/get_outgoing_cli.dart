import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../repositories/auth.dart';

class GetOutgoingCliUseCase extends UseCase<String, void> {
  final AuthRepository authRepository;

  GetOutgoingCliUseCase(this.authRepository);

  @override
  Future<Stream<String>> buildUseCaseStream(_) async {
    final controller = StreamController<String>();

    controller.add(authRepository.currentUser?.outgoingCli);
    unawaited(controller.close());

    return controller.stream;
  }
}
