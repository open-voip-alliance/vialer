import 'dart:io';

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
  final bool? bordered;

  SettingTile({
    super.key,
    this.label,
    this.description,
    required this.child,
    this.childFillWidth = false,
    this.center = false,
    EdgeInsetsGeometry? padding,
    this.bordered,
  }) : padding = padding ??
            EdgeInsets.only(
              top: Platform.isIOS ? 8 : 0,
              left: Platform.isIOS ? 16 : 24,
              right: 8,
              bottom: Platform.isIOS ? 8 : 0,
            );

  bool _shouldRenderBorder(BuildContext context) =>
      bordered != null ? bordered! : context.isIOS;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          decoration: _shouldRenderBorder(context)
              ? context.brand.theme.fieldBoxDecoration
              : null,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: !context.isIOS ? FontWeight.bold : null,
                        ),
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
            padding: EdgeInsets.only(
              left: context.isIOS ? 8 : 24,
              right: 8,
              top: context.isIOS ? 8 : 0,
              bottom: 16,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: context.brand.theme.colors.grey4,
              ),
              child: description!,
            ),
          ),
      ],
    );
  }
}
