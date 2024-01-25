import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../data/models/voipgrid/web_page.dart';
import '../../../../../shared/pages/web_view.dart';
import '../../../../../resources/localizations.dart';
import 'widget.dart';

class DialPlanLinkTile extends StatelessWidget {
  const DialPlanLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.dialplan.title,
      ),
      onTap: () => unawaited(WebViewPage.open(context, to: WebPage.dialPlan)),
    );
  }
}
