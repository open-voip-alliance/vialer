import '../../domain/entities/onboarding/step.dart';

import '../pages/onboarding/login/page.dart';
import '../pages/onboarding/password/page.dart';
import '../pages/onboarding/permission/call/page.dart';
import '../pages/onboarding/permission/contacts/page.dart';
import '../pages/onboarding/voicemail/page.dart';
import '../pages/onboarding/welcome/page.dart';

extension StepMapper on Step {
  Type get widgetType {
    switch (this) {
      case Step.login:
        return LoginPage;
      case Step.password:
        return PasswordPage;
      case Step.callPermission:
        return CallPermissionPage;
      case Step.contactsPermission:
        return ContactsPermissionPage;
      case Step.voicemail:
        return VoicemailPage;
      case Step.welcome:
        return WelcomePage;
      default:
        throw UnsupportedError('Unknown step');
    }
  }
}

extension StepMappers on Iterable<Step> {
  Iterable<Type> get widgetTypes => map((s) => s.widgetType);
}
