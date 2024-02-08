import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../data/models/user/user.dart';
import '../../../../../../../data/models/voipgrid/web_page.dart';
import '../../../../../shared/pages/web_view.dart';
import '../../../../../resources/localizations.dart';
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
      onTap: () => unawaited(
        WebViewPage.open(
          context,
          to: user.client.openingHoursModules.length == 1
              ? WebPage.openingHoursBasicEdit
              : WebPage.openingHoursBasicList,
        ),
      ),
    );
  }
}
