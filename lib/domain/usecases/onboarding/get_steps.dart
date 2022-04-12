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

  final _permissionSteps = {
    if (Platform.isAndroid) OnboardingStep.phonePermission: Permission.phone,
    OnboardingStep.contactsPermission: Permission.contacts,
    OnboardingStep.microphonePermission: Permission.microphone,
    if (Platform.isAndroid)
      OnboardingStep.bluetoothPermission: Permission.bluetooth,
    if (Platform.isAndroid)
      OnboardingStep.ignoreBatteryOptimizationsPermission:
          Permission.ignoreBatteryOptimizations,
    if (Platform.isIOS)
      OnboardingStep.notificationPermission: Permission.notifications,
  };

  Future<List<OnboardingStep>> call() async => [
        OnboardingStep.login,
        ...(await _generatePermissionSteps()),
        OnboardingStep.welcome,
      ];

  Future<List<OnboardingStep>> _generatePermissionSteps() async {
    final steps = <OnboardingStep>[];

    _permissionSteps.forEach((key, value) {
      if (_permissionRepository.getPermissionStatus(value) !=
          PermissionStatus.granted) {
        steps.add(key);
      }
    });

    return steps;
  }
}
