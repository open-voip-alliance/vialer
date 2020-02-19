import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

import '../../repositories/call_permission_repository.dart';

class RequestCallPermissionUseCase extends UseCase<bool, void> {
  final CallPermissionRepository _callPermissionRepository;

  RequestCallPermissionUseCase(this._callPermissionRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(_) async {
    final controller = StreamController<bool>();

    final granted = await _callPermissionRepository.enablePermission();

    controller.add(granted);
    await controller.close();

    return controller.stream;
  }
}