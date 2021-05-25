import 'package:flutter/material.dart';

import '../../../../../util/brand.dart';

class NoticeBanner extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  const NoticeBanner({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
    this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(4);

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        elevation: 4,
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: context.brand.theme.primaryGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        color: context.brand.theme.onPrimaryGradientColor,
                        size: 20,
                      ),
                      child: icon,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: context.brand.theme.onPrimaryGradientColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        child: title,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DefaultTextStyle.merge(
                    style: TextStyle(
                      color: context.brand.theme.onPrimaryGradientColor,
                      fontSize: 16,
                    ),
                    child: content),
                const SizedBox(height: 6),
                Theme(
                  data: theme.copyWith(
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        primary: context.brand.theme.onPrimaryGradientColor,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          shadows: [
                            BoxShadow(
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                              color: context.brand.theme.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
