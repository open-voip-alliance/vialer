import 'package:flutter/material.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class IgnoreBatteryOptimizationsPermissionPage extends StatelessWidget {
  const IgnoreBatteryOptimizationsPermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.ignoreBatteryOptimizations,
      icon: const Icon(VialerSans.battery),
      title: Text(
        context.msg.onboarding.permission.ignoreBatteryOptimizations.title,
      ),
      description: Text(
        context
            .msg.onboarding.permission.ignoreBatteryOptimizations.description,
      ),
    );
  }
}
