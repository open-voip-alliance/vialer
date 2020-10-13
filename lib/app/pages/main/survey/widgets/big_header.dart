import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';

class BigHeader extends StatelessWidget {
  final Widget icon;
  final Widget text;

  const BigHeader({
    Key key,
    @required this.icon,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(4),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.brandTheme.primary,
        ),
        child: Stack(
          children: [
            _HeaderBackgroundIcon.small(
              alignment: Alignment(-1.025, -1.2),
              child: icon,
            ),
            _HeaderBackgroundIcon.medium(
              alignment: Alignment(-0.95, 1),
              child: icon,
            ),
            _HeaderBackgroundIcon.large(
              alignment: Alignment(-0.6, -1),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: Alignment(-0.3, 0.9),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: Alignment(0, -0.95),
              child: icon,
            ),
            _HeaderBackgroundIcon.medium(
              alignment: Alignment(0.4, -0.1),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: Alignment(0.1, 1.5),
              child: icon,
            ),
            _HeaderBackgroundIcon.medium(
              alignment: Alignment(0.4, -0.1),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: Alignment(0.65, 1.2),
              child: icon,
            ),
            _HeaderBackgroundIcon.large(
              alignment: Alignment(0.9, -1.75),
              child: icon,
            ),
            _HeaderBackgroundIcon.small(
              alignment: Alignment(1.05, 0.7),
              child: icon,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.brandTheme.primary.withOpacity(0),
                    context.brandTheme.primary,
                  ],
                ),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
  final Alignment alignment;
  final double widthFactor;
  final Widget child;

  const _HeaderBackgroundIcon({
    Key key,
    @required this.alignment,
    @required this.widthFactor,
    @required this.child,
  }) : super(key: key);

  const _HeaderBackgroundIcon.small({
    Key key,
    @required this.alignment,
    @required this.child,
  })  : widthFactor = 0.075,
        super(key: key);

  const _HeaderBackgroundIcon.medium({
    Key key,
    @required this.alignment,
    @required this.child,
  })  : widthFactor = 0.125,
        super(key: key);

  const _HeaderBackgroundIcon.large({
    Key key,
    @required this.alignment,
    @required this.child,
  })  : widthFactor = 0.150,
        super(key: key);

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
