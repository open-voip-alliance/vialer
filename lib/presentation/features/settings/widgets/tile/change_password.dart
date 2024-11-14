import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/features/settings/pages/change_password_page.dart';
import 'package:vialer/presentation/features/settings/widgets/settings_button.dart';

import '../../../../../../data/models/user/user.dart';
import 'category/widget.dart';
import 'package:vialer/presentation/resources/localizations.dart';

class ChangePasswordTile extends StatelessWidget {
  const ChangePasswordTile(this.user, {super.key});
  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingTileCategory(
      icon: FontAwesomeIcons.lock,
      titleText: context.msg.main.settings.changePassword.title,
      bottomBorder: false,
      children: [
        SettingsButton(
          text: context.msg.main.settings.changePassword.description,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) {
                return ChangePasswordPage();
              },
            ),
          ),
        ),
      ],
    );
  }
}
