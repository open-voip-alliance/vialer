import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../abstract/controller.dart';
import '../abstract/page.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../../domain/entities/brand.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class ContactsPermissionPage extends StatelessWidget {
  final VoidCallback forward;

  const ContactsPermissionPage(
    this.forward, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      controller: PermissionController(
        Permission.contacts,
        forward,
      ),
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
