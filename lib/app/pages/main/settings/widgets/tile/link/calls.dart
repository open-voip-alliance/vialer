import 'package:flutter/material.dart';

import '../../../../../../../domain/voipgrid/web_page.dart';
import '../../../../../../resources/localizations.dart';
import '../../../../../web_view/page.dart';
import 'widget.dart';

class CallsLinkTile extends StatelessWidget {
  const CallsLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.calls.title,
      ),
      onTap: () => WebViewPage.route(context, to: WebPage.calls),
    );
  }
}
