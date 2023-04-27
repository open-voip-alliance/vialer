import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../util/brand.dart';
import '../abstract/page.dart';

class IgnoreBatteryOptimizationsPermissionPage extends StatelessWidget {
  const IgnoreBatteryOptimizationsPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.ignoreBatteryOptimizations,
      icon: const FaIcon(FontAwesomeIcons.batteryLow),
      title: Text(
        context.msg.onboarding.permission.ignoreBatteryOptimizations.title,
      ),
      description: Text(
        context.msg.onboarding.permission.ignoreBatteryOptimizations
            .description(context.brand.appName),
      ),
    );
  }
}
