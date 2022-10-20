import 'dart:async';
import 'dart:io';

import 'package:dartx/dartx.dart';

import '../../../dependency_locator.dart';
import '../use_case.dart';
import '../user/permissions/permission.dart';
import '../user/permissions/permission_repository.dart';
import '../user/permissions/permission_status.dart';
import 'step.dart';

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
    OnboardingStep.notificationPermission: Permission.notifications,
  };

  Future<List<OnboardingStep>> call() async => [
        OnboardingStep.login,
        ...(await _generatePermissionSteps()),
        OnboardingStep.welcome,
      ];

  Future<List<OnboardingStep>> _generatePermissionSteps() async {
    final steps = <OnboardingStep>[];

    for (var entry in _permissionSteps.entries) {
      if (await _permissionRepository.getPermissionStatus(entry.value) !=
          PermissionStatus.granted) {
        steps.add(entry.key);
      }
    }

    // We always want to show the contacts step on Android as we are
    // specifically requesting consent.
    if (Platform.isAndroid) {
      steps.add(OnboardingStep.contactsPermission);
    }

    return steps.distinct().toList(growable: false);
  }
}
