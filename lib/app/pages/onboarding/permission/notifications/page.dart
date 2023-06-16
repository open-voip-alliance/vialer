import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class NotificationsPermissionPage extends StatelessWidget {
  const NotificationsPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.notifications,
      icon: const FaIcon(FontAwesomeIcons.bell),
      title: context.msg.onboarding.permission.notifications.title,
      description: Text(
        context.msg.onboarding.permission.notifications.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
