import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class CallHeaderContainer extends StatelessWidget {
  final Widget child;

  const CallHeaderContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

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
      child: Container(
        decoration: BoxDecoration(
          gradient: context.brand.theme.primaryGradient,
        ),
        child: child,
      ),
    );
  }
}
