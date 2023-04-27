import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class CallHeaderContainer extends StatelessWidget {
  const CallHeaderContainer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'call-header-container',
      flightShuttleBuilder: (flightContext, _, __, ___, toHeroContext) {
        return DefaultTextStyle(
          style: DefaultTextStyle.of(toHeroContext).style,
          child: toHeroContext.widget,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: context.brand.theme.primaryGradient,
        ),
        child: child,
      ),
    );
  }
}
