import 'package:flutter/material.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';
import '../abstract/page.dart';

class ContactsPermissionPage extends StatelessWidget {
  const ContactsPermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.contacts,
      icon: const Icon(VialerSans.contacts),
      title: Text(context.msg.onboarding.permission.contacts.title),
      description: Text(
        context.msg.onboarding.permission.contacts.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
