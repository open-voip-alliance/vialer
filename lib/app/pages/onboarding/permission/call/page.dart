import 'package:flutter/material.dart';

import '../abstract/controller.dart';
import '../../../../resources/theme.dart';

import '../../../../../domain/entities/permission.dart';

import '../abstract/page.dart';

import '../../../../resources/localizations.dart';

class CallPermissionPage extends StatelessWidget {
  final VoidCallback forward;

  const CallPermissionPage(
    this.forward, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      controller: PermissionController(
        Permission.phone,
        forward,
      ),
      icon: Icon(VialerSans.phone),
      title: Text(
        context.msg.onboarding.permission.call.title,
        textAlign: TextAlign.center,
      ),
      description: Text(context.msg.onboarding.permission.call.description),
    );
  }
}
