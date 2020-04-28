import 'dart:async';
import 'dart:io';

import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:pedantic/pedantic.dart';

import '../../repositories/permission.dart';
import '../../entities/permission.dart';
import '../../entities/permission_status.dart';
import '../../entities/onboarding/step.dart';

class GetStepsUseCase extends UseCase<List<Step>, void> {
  final PermissionRepository permissionRepository;

  GetStepsUseCase(this.permissionRepository);

  @override
  Future<Stream<List<Step>>> buildUseCaseStream(_) async {
    final controller = StreamController<List<Step>>();

    var callPermissionDenied = false;
    if (Platform.isAndroid) {
      callPermissionDenied =
          await permissionRepository.getPermissionStatus(Permission.phone) !=
              PermissionStatus.granted;
    }

    final contactsPermissionDenied =
        await permissionRepository.getPermissionStatus(Permission.contacts) !=
            PermissionStatus.granted;

    final steps = [
      Step.login,
      if (callPermissionDenied) Step.callPermission,
      if (contactsPermissionDenied) Step.contactsPermission,
      Step.voicemail,
      Step.welcome,
    ];

    controller.add(steps);
    unawaited(controller.close());

    return controller.stream;
  }
}
