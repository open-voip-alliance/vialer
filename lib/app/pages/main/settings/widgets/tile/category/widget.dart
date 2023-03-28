import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../resources/theme.dart';

class SettingTileCategory extends StatelessWidget {
  // Not a Widget to keep it in line with the title, also no real need for it.
  final IconData icon;

  // String instead of Widget, because we need to call .toUppercaseOnAndroid
  // every time.
  final String? titleText;

  final Widget? title;

  final bool highlight;
  final List<Widget> children;
  final bool padBottom;
  final bool bottomBorder;

  const SettingTileCategory({
    Key? key,
    required this.icon,
    this.titleText,
    this.title,
    this.highlight = false,
    this.children = const [],
    this.padBottom = false,
    this.bottomBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(
      (title != null && titleText == null) ||
          (title == null && titleText != null),
      'You must provide either a title or a titleWidget, not both.',
    );

    const dividerHeight = 2.0;
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
              bottom: (padBottom ? 8 : 0) + dividerPadding,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: FaIcon(
                            icon,
                            color: Theme.of(context).primaryColor,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (title != null) title!,
                    if (titleText != null)
                      Text(
                        titleText!.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ...children,
              ],
            ),
          ),
        ),
        if (bottomBorder)
          Divider(
            height: dividerHeight,
            color: context.brand.theme.colors.grey6,
          ),
      ],
    );
  }
}
