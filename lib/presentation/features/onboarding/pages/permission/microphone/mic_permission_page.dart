import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../../../../../../data/models/user/permissions/permission.dart';
import '../abstract/permission_page.dart';

class MicrophonePermissionPage extends StatelessWidget {
  const MicrophonePermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PermissionPage(
      permission: Permission.microphone,
      icon: const FaIcon(FontAwesomeIcons.microphone),
      title: context.msg.onboarding.permission.microphone.title,
      description: Text(
        context.msg.onboarding.permission.microphone.description(
          context.brand.appName,
        ),
      ),
    );
  }
}
