import 'dart:async';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:vialer_lite/domain/entities/onboarding/permission_status.dart';

import '../../repositories/call_permission_repository.dart';
import '../../entities/onboarding/step.dart';

class GetStepsUseCase extends UseCase<List<Step>, void> {
  final CallPermissionRepository callPermissionRepository;

  GetStepsUseCase(this.callPermissionRepository);

  @override
  Future<Stream<List<Step>>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Step>>();

    final callPermissionDenied =
        await callPermissionRepository.getPermissionStatus() ==
            PermissionStatus.denied;

    final steps = [
      Step.initial,
      Step.login,
      if (callPermissionDenied) Step.callPermission,
    ];

    controller.add(steps);
    controller.close();

    return controller.stream;
  }
}
