import 'package:flutter/material.dart';

import 'package:vialer/presentation/resources/theme.dart';

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
        return SingleChildScrollView(
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(toHeroContext).style,
            child: toHeroContext.widget,
          ),
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
