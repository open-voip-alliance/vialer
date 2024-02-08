import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/data/models/voipgrid/web_page.dart';

import '../../../../resources/localizations.dart';
import '../../../../shared/pages/web_view.dart';
import 'category/widget.dart';

class FeatureAnnouncementTile extends StatelessWidget {
  const FeatureAnnouncementTile({
    super.key,
    required this.hasUnreadFeatureAnnouncements,
  });

  final bool hasUnreadFeatureAnnouncements;

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
      showBadge: hasUnreadFeatureAnnouncements,
    );
  }
}
