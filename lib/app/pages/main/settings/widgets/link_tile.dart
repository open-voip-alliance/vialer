import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/entities/portal_page.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';
import '../../../web_view/page.dart';
import '../cubit.dart';
import '../sub_page.dart';
import 'tile.dart';

class SettingLinkTile extends StatelessWidget {
  final Widget title;
  final Widget? description;

  final VoidCallback? onTap;

  const SettingLinkTile({
    Key? key,
    required this.title,
    this.description,
    this.onTap,
  }) : super(key: key);

  static Widget troubleshooting() {
    return Builder(
      builder: (context) {
        return SettingLinkTile(
          title: Text(
            context
                .msg.main.settings.list.advancedSettings.troubleshooting.title,
          ),
          description: Text(
            context.msg.main.settings.list.advancedSettings.troubleshooting
                .description,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return SettingsSubPage.troubleshooting(
                  cubit: context.read<SettingsCubit>(),
                );
              }),
            );
          },
        );
      },
    );
  }

  static Widget dialPlan() {
    return Builder(
      builder: (context) {
        return SettingLinkTile(
          title: Text(
            context.msg.main.settings.list.portalLinks.dialplan.title,
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => PortalWebViewPage(PortalPage.dialPlan),
              ),
            );
          },
        );
      },
    );
  }

  static Widget stats() {
    return Builder(
      builder: (context) {
        return SettingLinkTile(
          title: Text(
            context.msg.main.settings.list.portalLinks.stats.title,
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => PortalWebViewPage(PortalPage.stats),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: SettingTile(
        label: title,
        description: description,
        child: Icon(
          VialerSans.caretRight,
          color: context.brand.theme.grey4,
        ),
      ),
    );
  }
}
