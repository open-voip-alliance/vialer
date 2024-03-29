import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../../../data/models/voipgrid/web_page.dart';
import '../../../../../resources/localizations.dart';
import '../../../../../shared/pages/web_view.dart';
import 'widget.dart';

class CallsLinkTile extends StatelessWidget {
  const CallsLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTile(
      title: Text(
        context.msg.main.settings.list.portalLinks.calls.title,
      ),
      onTap: () => unawaited(WebViewPage.open(context, to: WebPage.calls)),
    );
  }
}
