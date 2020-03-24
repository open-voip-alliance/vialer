import 'package:flutter/material.dart';

class StylizedButton extends StatelessWidget {
  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.decelerate;

  static const _borderWidth = 1.0;
  static const _bottomBorderWidth = 2.0;

  final _Type _type;
  final bool colored;
  final VoidCallback onPressed;
  final Widget child;

  StylizedButton._(
    this._type, {
    Key key,
    this.colored = false,
    this.onPressed,
    this.child,
  }) : super(key: key);

  factory StylizedButton.raised({
    Key key,
    bool colored = false,
    VoidCallback onPressed,
    Widget child,
  }) {
    return StylizedButton._(
      _Type.raised,
      key: key,
      colored: colored,
      onPressed: onPressed,
      child: child,
    );
  }

  factory StylizedButton.outline({
    Key key,
    bool colored = false,
    VoidCallback onPressed,
    Widget child,
  }) {
    return StylizedButton._(
      _Type.outline,
      key: key,
      colored: colored,
      onPressed: onPressed,
      child: child,
    );
  }

  factory StylizedButton.flat({
    Key key,
    bool colored = false,
    VoidCallback onPressed,
    Widget child,
  }) {
    return StylizedButton._(
      _Type.flat,
      key: key,
      colored: colored,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(2);
    final primaryLight = Theme.of(context).primaryColorLight;
    final primaryDark = Theme.of(context).primaryColorDark;

    final disabled = onPressed == null;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(borderRadius),
    );

    final isRaised = _type == _Type.raised;
    final isOutline = _type == _Type.outline;
    final isFlat = _type == _Type.flat;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        decoration: BoxDecoration(
          boxShadow: [
            if (!disabled && isRaised)
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: shape.borderRadius,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            decoration: BoxDecoration(
              // Always draw a border to avoid size differences between other
              // types
              border: isOutline
                  ? Border.all(
                      color: colored ? primaryLight : Colors.white,
                      width: _borderWidth,
                    )
                  : null,
              borderRadius: shape.borderRadius,
              color: disabled
                  ? Color(0xFFF5F5F5)
                  : isRaised
                      ? (colored ? primaryLight : Colors.white)
                      : Colors.transparent,
            ),
            child: CustomPaint(
              painter: _BottomBorderPainter(
                enabled: !isFlat,
                thickness: isRaised
                    ? _bottomBorderWidth
                    : _bottomBorderWidth - _borderWidth,
                color: isOutline
                    ? (colored
                        ? Theme.of(context).primaryColorLight
                        : Colors.white)
                    : (colored
                        ? Theme.of(context).primaryColor
                        : Color(0xFFE0E0E0)),
              ),
              child: Material(
                color: Colors.transparent,
                shape: shape,
                child: InkWell(
                  customBorder: shape,
                  onTap: onPressed,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12 + (!isOutline ? 1.0 : 0.0),
                      horizontal: 16 + (!isOutline ? 1.0 : 0.0),
                    ),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duration,
                        curve: _curve,
                        style: TextStyle(
                          color: disabled
                              ? Color(0xFF555555)
                              : colored || _type == _Type.raised
                                  ? primaryDark
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Type {
  raised,
  outline,
  flat,
}

class _BottomBorderPainter extends CustomPainter {
  final bool enabled;
  final Color color;
  final double thickness;

  _BottomBorderPainter({
    this.enabled = true,
    @required this.color,
    @required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (enabled) {
      canvas.drawRect(
        Rect.fromPoints(
          Offset(-2, size.height - thickness),
          Offset(size.width + 2, size.height + thickness),
        ),
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_BottomBorderPainter oldDelegate) =>
      color != oldDelegate.color || thickness != oldDelegate.thickness;
}
