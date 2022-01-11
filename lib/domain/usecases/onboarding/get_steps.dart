import 'dart:async';
import 'dart:io';

import '../../../dependency_locator.dart';
import '../../entities/onboarding/step.dart';
import '../../entities/permission.dart';
import '../../entities/permission_status.dart';
import '../../repositories/permission.dart';
import '../../use_case.dart';

class GetOnboardingStepsUseCase extends UseCase {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  Future<List<OnboardingStep>> call() async {
    var phonePermissionDenied = false;
    var bluetoothPermissionDenied = false;
    if (Platform.isAndroid) {
      phonePermissionDenied =
          await _permissionRepository.getPermissionStatus(Permission.phone) !=
              PermissionStatus.granted;

      bluetoothPermissionDenied = await _permissionRepository
              .getPermissionStatus(Permission.bluetooth) !=
          PermissionStatus.granted;
    }

    final contactsPermissionDenied =
        await _permissionRepository.getPermissionStatus(Permission.contacts) !=
            PermissionStatus.granted;

    final microphonePermissionDenied = await _permissionRepository
            .getPermissionStatus(Permission.microphone) !=
        PermissionStatus.granted;

    return [
      OnboardingStep.login,
      if (phonePermissionDenied) OnboardingStep.phonePermission,
      if (contactsPermissionDenied) OnboardingStep.contactsPermission,
      if (microphonePermissionDenied) OnboardingStep.microphonePermission,
      if (bluetoothPermissionDenied) OnboardingStep.bluetoothPermission,
      OnboardingStep.welcome,
    ];
  }
}
