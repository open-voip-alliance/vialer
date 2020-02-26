import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../../repositories/call_permission.dart';

class RequestPermissionUseCase extends UseCase<bool, void> {
  final PermissionRepository _callPermissionRepository;

  RequestPermissionUseCase(this._callPermissionRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(_) async {
    final controller = StreamController<bool>();

    final granted = await _callPermissionRepository.enablePermission();

    controller.add(granted);
    unawaited(controller.close());

    return controller.stream;
  }
}
