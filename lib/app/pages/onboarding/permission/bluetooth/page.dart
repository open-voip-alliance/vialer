import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class BluetoothPermissionPage extends StatelessWidget {
  const BluetoothPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.bluetooth,
      icon: const FaIcon(FontAwesomeIcons.bluetooth),
      title: context.msg.onboarding.permission.bluetooth.title,
      description: Text(
        context.msg.onboarding.permission.bluetooth.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
