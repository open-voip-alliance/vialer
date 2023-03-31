import 'package:flutter/material.dart';

import '../../../../../../../domain/user/user.dart';
import '../../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../web_view/page.dart';
import 'widget.dart';

class OpeningHoursLinkTile extends StatelessWidget {
  final User user;

  const OpeningHoursLinkTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.openingHours.title,
      ),
      onTap: () => WebViewPage.route(
        context,
        to: user.client.openingHours.length == 1
            ? WebPage.openingHoursBasicEdit
            : WebPage.openingHoursBasicList,
      ),
    );
  }
}
