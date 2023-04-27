import 'package:flutter/material.dart';

import '../../../../../../../domain/user/user.dart';
import '../../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../web_view/page.dart';
import 'widget.dart';

class OpeningHoursLinkTile extends StatelessWidget {
  const OpeningHoursLinkTile(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.openingHours.title,
      ),
      onTap: () => WebViewPage.open(
        context,
        to: user.client.openingHoursModules.length == 1
            ? WebPage.openingHoursBasicEdit
            : WebPage.openingHoursBasicList,
      ),
    );
  }
}
