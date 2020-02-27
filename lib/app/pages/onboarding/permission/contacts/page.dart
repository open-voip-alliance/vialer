import 'package:flutter/material.dart';

import '../abstract/controller.dart';
import '../../../../resources/theme.dart';
import '../../../../../device/repositories/permission.dart';
import '../../../../../domain/entities/onboarding/permission.dart';

import '../abstract/page.dart';

import '../../../../resources/localizations.dart';

class ContactsPermissionPage extends StatelessWidget {
  final VoidCallback forward;

  const ContactsPermissionPage(this.forward, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      controller: PermissionController(
        Permission.contacts,
        DevicePermissionRepository(),
        forward,
      ),
      icon: Icon(VialerSans.contacts),
      title: Text(
        context.msg.onboarding.permission.contacts.title,
        textAlign: TextAlign.center,
      ),
      description: Text(
        context.msg.onboarding.permission.contacts.description,
      ),
    );
  }
}
