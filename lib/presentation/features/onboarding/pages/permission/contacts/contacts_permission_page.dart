import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/user/permissions/permission.dart';
import '../abstract/permission_page.dart';

class ContactsPermissionPage extends StatelessWidget {
  const ContactsPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.contacts,
      icon: const FaIcon(FontAwesomeIcons.addressBook),
      title: context.msg.onboarding.permission.contacts.title,
      description: Text(
        context.msg.onboarding.permission.contacts
            .description(context.brand.appName),
      ),
    );
  }
}
