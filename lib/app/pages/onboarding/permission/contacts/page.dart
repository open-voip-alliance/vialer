import 'package:flutter/material.dart';

import '../abstract/controller.dart';
import '../../../../resources/theme.dart';
import '../../../../../device/repositories/permission.dart';
import '../../../../../domain/entities/onboarding/permission.dart';

import '../abstract/page.dart';

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
        'Contacts permission',
        textAlign: TextAlign.center,
      ),
      description: Text(
        'This permissions is required to view contacts in-app.',
      ),
    );
  }
}
