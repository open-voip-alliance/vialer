import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../domain/entities/brand.dart';
import '../../../../../domain/entities/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../abstract/page.dart';

class ContactsPermissionPage extends StatelessWidget {
  const ContactsPermissionPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.contacts,
      icon: Icon(VialerSans.contacts),
      title: Text(
        context.msg.onboarding.permission.contacts.title,
        textAlign: TextAlign.center,
      ),
      description: Text(
        context.msg.onboarding.permission.contacts.description(
          Provider.of<Brand>(context).appName,
        ),
      ),
    );
  }
}
