import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class BigHeader extends StatelessWidget {
  const BigHeader({
    required this.icon,
    required this.text,
    super.key,
  });

  final Widget icon;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.brand.theme.colors.primary,
        ),
        child: Stack(
          children: [
            _HeaderBackgroundIcon.small(
              alignment: const Alignment(-1.025, -1.2),
              child: icon,
            ),
            _HeaderBackgroundIcon.medium(
              alignment: const Alignment(-0.95, 1),
              child: icon,
            ),
            _HeaderBackgroundIcon.large(
              alignment: const Alignment(-0.6, -1),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: const Alignment(-0.3, 0.9),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: const Alignment(0, -0.95),
              child: icon,
            ),
            _HeaderBackgroundIcon.medium(
              alignment: const Alignment(0.4, -0.1),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: const Alignment(0.1, 1.5),
              child: icon,
            ),
            _HeaderBackgroundIcon.medium(
              alignment: const Alignment(0.4, -0.1),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: const Alignment(0.65, 1.2),
              child: icon,
            ),
            _HeaderBackgroundIcon.large(
              alignment: const Alignment(0.9, -1.75),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: const Alignment(1.05, 0.7),
              child: icon,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.brand.theme.colors.primary.withOpacity(0),
                    context.brand.theme.colors.primary,
                  ],
                ),
              ),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBackgroundIcon extends StatelessWidget {
  const _HeaderBackgroundIcon({
    required this.alignment,
    required this.widthFactor,
    required this.child,
  });

  const _HeaderBackgroundIcon.small({
    required this.alignment,
    required this.child,
  }) : widthFactor = 0.075;

  const _HeaderBackgroundIcon.medium({
    required this.alignment,
    required this.child,
  }) : widthFactor = 0.125;

  const _HeaderBackgroundIcon.large({
    required this.alignment,
    required this.child,
  }) : widthFactor = 0.150;

  final Alignment alignment;
  final double widthFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: FractionallySizedBox(
          widthFactor: widthFactor,
          child: child,
        ),
      ),
    );
  }
}
