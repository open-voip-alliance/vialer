import 'package:flutter/material.dart';

import '../../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../web_view/page.dart';
import 'widget.dart';

class DialPlanLinkTile extends StatelessWidget {
  const DialPlanLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.dialplan.title,
      ),
      onTap: () => WebViewPage.route(context, to: WebPage.dialPlan),
    );
  }
}
