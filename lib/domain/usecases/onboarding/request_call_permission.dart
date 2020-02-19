import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:vialer_lite/domain/entities/onboarding/permission_status.dart';
import 'package:vialer_lite/domain/repositories/auth_repository.dart';

import '../../repositories/call_permission_repository.dart';
import '../../entities/onboarding/step.dart';

class RequestCallPermissionUseCase extends UseCase<bool, void> {
  final CallPermissionRepository _callPermissionRepository;

  RequestCallPermissionUseCase(this._callPermissionRepository);

  @override
  Future<Stream<bool>> buildUseCaseStream(_) async {
    final controller = StreamController<bool>();

    final granted = await _callPermissionRepository.enablePermission();

    controller.add(granted);
    controller.close();

    return controller.stream;
  }
}