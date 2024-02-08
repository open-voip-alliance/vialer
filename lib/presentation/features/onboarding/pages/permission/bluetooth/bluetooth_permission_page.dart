import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../data/models/user/permissions/permission.dart';
import '../abstract/permission_page.dart';

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
