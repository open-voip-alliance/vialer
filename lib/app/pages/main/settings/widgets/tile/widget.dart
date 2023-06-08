import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../resources/theme.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.child,
    this.label,
    this.description,
    this.childFillWidth = false,
    this.center = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.mergeSemantics = true,
    super.key,
  });

  final Widget? label;
  final Widget? description;

  /// The widget that presents the setting's value.
  final Widget child;

  /// If this is true, the [child] will be the maximum width and on the
  /// next line. Defaults to false.
  final bool childFillWidth;

  /// If this is true, the widget will be centered.
  final bool center;

  final EdgeInsets padding;

  final bool mergeSemantics;

  @override
  Widget build(BuildContext context) {
    final widget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
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
            padding: padding.copyWith(top: 8, bottom: 16),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brand.theme.colors.grey4,
                fontSize: 14,
              ),
              child: description!,
            ),
          ),
      ],
    );

    return mergeSemantics ? MergeSemantics(child: widget) : widget;
  }
}
