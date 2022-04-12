import 'package:flutter/material.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class NotificationsPermissionPage extends StatelessWidget {
  const NotificationsPermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.notifications,
      icon: const Icon(VialerSans.available),
      title: Text(
        context.msg.onboarding.permission.notifications.title,
      ),
      description: Text(
        context.msg.onboarding.permission.notifications.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
