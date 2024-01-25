import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../../domain/usecases/user/launch_privacy_policy.dart';
import 'category/widget.dart';

class PrivacyPolicyTile extends StatelessWidget {
  const PrivacyPolicyTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingLinkTileCategory(
      onTap: () => LaunchPrivacyPolicy()(),
      text: context.msg.main.settings.privacyPolicy,
      icon: FontAwesomeIcons.bookCircleArrowRight,
    );
  }
}
