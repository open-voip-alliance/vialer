import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../web_view/page.dart';
import 'widget.dart';

class StatsLinkTile extends StatelessWidget {
  const StatsLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.stats.title,
      ),
      onTap: () => unawaited(WebViewPage.open(context, to: WebPage.stats)),
    );
  }
}
