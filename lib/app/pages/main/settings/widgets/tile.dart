import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class SettingTile extends StatelessWidget {
  final Widget label;
  final Widget description;

  /// The widget that presents the [setting]s value.
  final Widget child;

  /// If this is true, the [child] will be the maximum width and on the
  /// next line. Defaults to false.
  final bool childFillWidth;

  const SettingTile({
    Key key,
    @required this.label,
    this.description,
    this.child,
    this.childFillWidth = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            decoration: context.isIOS
                ? BoxDecoration(
                    border: Border.all(
                      color: context.brandTheme.grey2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            padding: EdgeInsets.only(
              top: context.isIOS ? 8 : 0,
              left: context.isIOS ? 16 : 24,
              right: 8,
              bottom: context.isIOS ? 8 : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: 48,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: !context.isIOS ? FontWeight.bold : null,
                        ),
                        child: label,
                      ),
                      if (!childFillWidth) child,
                    ],
                  ),
                ),
                if (childFillWidth) child,
              ],
            )),
        if (description != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: context.isIOS ? 8 : 24,
              right: 8,
              top: context.isIOS ? 8 : 0,
              bottom: 16,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brandTheme.grey4,
              ),
              child: description,
            ),
          ),
        ],
      ],
    );
  }
}
