import 'dart:async';
import 'dart:io';

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
      final permission = entry.value;

      if (await _isPermissionNotGranted(permission)) {
        steps.add(entry.key);
      } else if (_shouldShowStepEvenIfPermissionGranted(permission)) {
        steps.add(entry.key);
      }
    }

    return steps;
  }

  Future<bool> _isPermissionNotGranted(Permission permission) =>
      _permissionRepository
          .getPermissionStatus(permission)
          .then((value) => value != PermissionStatus.granted);

  /// We always want to show the contacts step on Android as we are
  /// specifically requesting consent.
  bool _shouldShowStepEvenIfPermissionGranted(Permission permission) =>
      Platform.isAndroid && permission == Permission.contacts;
}
