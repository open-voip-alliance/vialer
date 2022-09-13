import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/entities/permission.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

import '../abstract/page.dart';

class MicrophonePermissionPage extends StatelessWidget {
  const MicrophonePermissionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.microphone,
      icon: const FaIcon(FontAwesomeIcons.microphone),
      title: Text(context.msg.onboarding.permission.microphone.title),
      description: Text(
        context.msg.onboarding.permission.microphone.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
