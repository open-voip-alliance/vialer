import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';

class SettingTileCategory extends StatelessWidget {
  // Not a Widget to keep it in line with the title, also no real need for it.
  final IconData icon;

  // String instead of Widget, because we need to call .toUppercaseOnAndroid
  // every time.
  final String title;

  final bool highlight;
  final List<Widget> children;

  const SettingTileCategory({
    Key? key,
    required this.icon,
    required this.title,
    this.highlight = false,
    this.children = const [],
  }) : super(key: key);

  static Widget accountInfo({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          highlight: true,
          icon: FontAwesomeIcons.user,
          title: context.msg.main.settings.list.accountInfo.title,
          children: children,
        );
      },
    );
  }

  static Widget audio({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          icon: FontAwesomeIcons.volume,
          title: context.msg.main.settings.list.audio.title,
          children: children,
        );
      },
    );
  }

  static Widget calling({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          icon: FontAwesomeIcons.phone,
          title: context.msg.main.settings.list.calling.title,
          children: children,
        );
      },
    );
  }

  static Widget debug({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          icon: FontAwesomeIcons.bug,
          title: context.msg.main.settings.list.debug.title,
          children: children,
        );
      },
    );
  }

  static Widget advancedSettings({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          icon: FontAwesomeIcons.bug,
          title: context.msg.main.settings.list.advancedSettings.title,
          children: children,
        );
      },
    );
  }

  static Widget troubleshootingAudio({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          icon: FontAwesomeIcons.volume,
          title: context.msg.main.settings.list.advancedSettings.troubleshooting
              .list.audio.title,
          children: children,
        );
      },
    );
  }

  static Widget portalLinks({List<Widget> children = const []}) {
    return Builder(
      builder: (context) {
        return SettingTileCategory(
          icon: FontAwesomeIcons.browsers,
          title: context.msg.main.settings.list.portalLinks.title,
          children: context.isIOS
              ? children
                  .mapIndexed(
                    (index, child) => index != children.lastIndex
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: child,
                          )
                        : child,
                  )
                  .toList()
              : children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const dividerHeight = 1.0;
    // Default divider height halved, minus 1 for the thickness (actual height
    // in our case).
    const dividerPadding = 16 / 2 - dividerHeight;

    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: highlight
                ? context.brand.theme.colors.settingsBackgroundHighlight
                : null,
            border: highlight
                ? Border(
                    top: BorderSide(
                      width: 0,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(
              top: 8 + dividerPadding,
              bottom: dividerPadding,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    FaIcon(
                      icon,
                      color: context.brand.theme.colors.grey1,
                      size: !context.isIOS ? 16 : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title.toUpperCaseIfAndroid(context),
                      style: TextStyle(
                        color: !context.isIOS
                            ? Theme.of(context).primaryColor
                            : null,
                        fontSize: context.isIOS ? 18 : 14,
                        fontWeight: context.isIOS ? null : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.isIOS ? 16 : 8),
                ...children,
              ],
            ),
          ),
        ),
        // We don't use the default height so the highlight background color
        // ends exactly at the divider.
        if (!context.isIOS) const Divider(height: dividerHeight),
      ],
    );
  }
}
