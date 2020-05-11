import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../repositories/storage.dart';

class GetLatestDialedNumber extends UseCase<String, void> {
  final StorageRepository _storageRepository;

  GetLatestDialedNumber(this._storageRepository);

  @override
  Future<Stream<String>> buildUseCaseStream(_) async {
    final controller = StreamController<String>();

    controller.add(await _storageRepository.lastDialedNumber);
    unawaited(controller.close());

    return controller.stream;
  }
}
