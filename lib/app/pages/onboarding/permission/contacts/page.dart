import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/user/permissions/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class ContactsPermissionPage extends StatelessWidget {
  const ContactsPermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.contacts,
      icon: const FaIcon(FontAwesomeIcons.addressBook),
      title: Text(context.msg.onboarding.permission.contacts.title),
      description: Text(
        context.msg.onboarding.permission.contacts.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
