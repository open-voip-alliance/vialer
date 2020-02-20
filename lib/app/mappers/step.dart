import '../../domain/entities/onboarding/step.dart';

import '../pages/onboarding/initial/page.dart';
import '../pages/onboarding/login/page.dart';
import '../pages/onboarding/permission/call/page.dart';

Type mapStepToWidgetType(Step step) {
  switch (step) {
    case Step.initial:
      return InitialPage;
    case Step.login:
      return LoginPage;
    case Step.callPermission:
      return CallPermissionPage;
    default:
      throw UnsupportedError('Unknown step');
  }
}

Iterable<Type> mapStepsToWidgetTypes(Iterable<Step> steps) =>
    steps.map(mapStepToWidgetType);
