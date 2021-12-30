import 'package:flutter/material.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class BluetoothPermissionPage extends StatelessWidget {
  const BluetoothPermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.bluetooth,
      icon: const Icon(VialerSans.bluetooth),
      title: Text(context.msg.onboarding.permission.bluetooth.title),
      description: Text(
        context.msg.onboarding.permission.bluetooth.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
