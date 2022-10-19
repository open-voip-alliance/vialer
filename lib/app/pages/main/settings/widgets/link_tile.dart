import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../domain/voipgrid/web_page.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../web_view/page.dart';
import '../cubit.dart';
import '../sub_page.dart';
import 'tile.dart';

class SettingLinkTile extends StatelessWidget {
  final Widget title;
  final Widget? description;

  final VoidCallback? onTap;

  final bool center;

  /// See [SettingTile.bordered] for more information.
  final bool? bordered;

  /// When TRUE will show a right-arrow indicating to the user that pressing
  /// this navigates to another page.
  final bool showNavigationIndicator;

  const SettingLinkTile({
    Key? key,
    required this.title,
    this.description,
    this.onTap,
    this.center = false,
    this.bordered,
    this.showNavigationIndicator = true,
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
                builder: (context) => WebViewPage(WebPage.dialPlan),
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
                builder: (context) => WebViewPage(WebPage.stats),
              ),
            );
          },
        );
      },
    );
  }

  static Widget calls() {
    return Builder(
      builder: (context) {
        return SettingLinkTile(
          title: Text(
            context.msg.main.settings.list.portalLinks.calls.title,
          ),
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => WebViewPage(WebPage.calls),
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
        center: center,
        bordered: bordered,
        child: showNavigationIndicator
            ? FaIcon(
                FontAwesomeIcons.angleRight,
                color: context.brand.theme.colors.grey4,
              )
            : Container(),
      ),
    );
  }
}
