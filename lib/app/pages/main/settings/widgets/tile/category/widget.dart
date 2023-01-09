import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/theme.dart';
import '../../../../../../util/conditional_capitalization.dart';

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
