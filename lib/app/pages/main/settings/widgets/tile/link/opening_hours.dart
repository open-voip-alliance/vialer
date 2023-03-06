import 'package:flutter/material.dart';

import '../../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../web_view/page.dart';
import 'widget.dart';

class OpeningHoursLinkTile extends StatelessWidget {
  const OpeningHoursLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.openingHours.title,
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => WebViewPage(WebPage.openingHoursBasicEdit),
          ),
        );
      },
    );
  }
}
