import 'dart:async';
import 'dart:io';

import '../../../dependency_locator.dart';
import '../../use_case.dart';
import '../../repositories/permission.dart';
import '../../entities/permission.dart';
import '../../entities/permission_status.dart';
import '../../entities/onboarding/step.dart';

class GetOnboardingStepsUseCase extends FutureUseCase<List<OnboardingStep>> {
  final _permissionRepository = dependencyLocator<PermissionRepository>();

  @override
  Future<List<OnboardingStep>> call() async {
    var callPermissionDenied = false;
    if (Platform.isAndroid) {
      callPermissionDenied =
          await _permissionRepository.getPermissionStatus(Permission.phone) !=
              PermissionStatus.granted;
    }

    final contactsPermissionDenied =
        await _permissionRepository.getPermissionStatus(Permission.contacts) !=
            PermissionStatus.granted;

    return [
      OnboardingStep.login,
      if (callPermissionDenied) OnboardingStep.callPermission,
      if (contactsPermissionDenied) OnboardingStep.contactsPermission,
      OnboardingStep.voicemail,
      OnboardingStep.welcome,
    ];
  }
}
