import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../domain/user/launch_privacy_policy.dart';
import '../../../../../resources/localizations.dart';
import 'category/widget.dart';

class PrivacyPolicyTile extends StatelessWidget {
  const PrivacyPolicyTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LaunchPrivacyPolicy()(),
      child: SettingTileCategory(
        icon: FontAwesomeIcons.bookCircleArrowRight,
        title: context.msg.main.settings.privacyPolicy,
        padBottom: true,
      ),
    );
  }
}
