import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/domain/voipgrid/web_page.dart';

import '../../../../../resources/localizations.dart';
import '../../../../web_view/page.dart';
import 'category/widget.dart';

class FeatureAnnouncementTile extends StatelessWidget {
  const FeatureAnnouncementTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingLinkTileCategory(
      onTap: () => unawaited(
        WebViewPage.open(
          context,
          to: WebPage.featureAnnouncements,
        ),
      ),
      text: context.msg.main.settings.featureAnnouncement.title,
      icon: FontAwesomeIcons.bell,
      showBadge: true,
    );
  }
}
