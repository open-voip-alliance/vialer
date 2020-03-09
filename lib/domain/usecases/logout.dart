import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';
import '../repositories/storage.dart';

class LogoutUseCase extends UseCase<void, void> {
  final StorageRepository _storageRepository;

  LogoutUseCase(this._storageRepository);

  @override
  Future<Stream<void>> buildUseCaseStream(_) async {
    final controller = StreamController<void>();

    await _storageRepository.clear();

    unawaited(controller.close());

    return controller.stream;
  }
}
