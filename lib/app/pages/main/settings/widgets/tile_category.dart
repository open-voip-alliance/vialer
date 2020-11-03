import 'package:flutter/material.dart';

import '../../../../entities/category.dart';
import '../../../../entities/category_info.dart';

import '../../../../resources/theme.dart';
import '../../../../util/conditional_capitalization.dart';

class SettingTileCategory extends StatelessWidget {
  final CategoryInfo info;
  final List<Widget> children;
  final EdgeInsets padding;

  const SettingTileCategory({
    Key key,
    this.info,
    this.padding = EdgeInsets.zero,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = info.item;

    const dividerHeight = 1.0;
    // Default divider height halved, minus 1 for the thickness (actual height
    // in our case).
    const dividerPadding = 16 / 2 - dividerHeight;

    return Column(
      children: <Widget>[
        Container(
          color: category == Category.accountInfo
              ? context.brandTheme.settingsBackgroundHighlight
              : null,
          child: Padding(
            padding: padding.copyWith(
              top: padding.top + dividerPadding,
              bottom: padding.bottom + dividerPadding,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      info.icon,
                      color: context.brandTheme.grey1,
                      size: !context.isIOS ? 16 : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      info.title.toUpperCaseIfAndroid(context),
                      style: TextStyle(
                        color: !context.isIOS
                            ? Theme.of(context).primaryColor
                            : null,
                        fontSize: context.isIOS ? 18 : 12,
                        fontWeight: context.isIOS ? null : FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (context.isIOS) const SizedBox(height: 16),
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
