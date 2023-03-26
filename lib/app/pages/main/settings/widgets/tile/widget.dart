import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../resources/theme.dart';

class SettingTile extends StatelessWidget {
  final Widget? label;
  final Widget? description;

  /// The widget that presents the [setting]s value.
  final Widget child;

  /// If this is true, the [child] will be the maximum width and on the
  /// next line. Defaults to false.
  final bool childFillWidth;

  /// If this is true, the widget will be centered.
  final bool center;

  final EdgeInsetsGeometry? padding;

  /// Specify if a border should be shown, if null, platform defaults
  /// will be used.
  final bool bordered;

  SettingTile({
    super.key,
    this.label,
    this.description,
    required this.child,
    this.childFillWidth = false,
    this.center = false,
    this.bordered = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: bordered ? context.brand.theme.fieldBoxDecoration : null,
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (label != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: double.infinity,
                    minHeight: 48,
                  ),
                  child: Row(
                    mainAxisAlignment: center
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DefaultTextStyle.merge(
                        style: const TextStyle(fontSize: 15),
                        child: center
                            ? label!
                            : Expanded(
                                child: label!,
                              ),
                      ),
                      if (!childFillWidth) child,
                    ],
                  ),
                ),
              if (childFillWidth || label == null) child,
            ],
          ),
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brand.theme.colors.grey4,
                fontSize: 12,
              ),
              child: description!,
            ),
          ),
      ],
    );
  }
}
