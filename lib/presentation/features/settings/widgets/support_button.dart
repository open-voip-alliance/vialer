import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/widgets/settings_button.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../domain/usecases/user/launch_support_page.dart';

class SupportButton extends StatelessWidget {
  const SupportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SettingsButton(
        text: context.msg.main.settings.support.button.title,
        icon: FontAwesomeIcons.headset,
        onPressed: LaunchSupportPage(),
      ),
    );
  }
}
