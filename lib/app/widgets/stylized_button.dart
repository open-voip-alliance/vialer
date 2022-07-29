import 'package:flutter/material.dart';

import '../resources/theme.dart';

class StylizedButton extends StatelessWidget {
  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.decelerate;

  static const _borderWidth = 1.0;
  static const _bottomBorderWidth = 2.0;

  final _Type _type;
  final bool colored;
  final VoidCallback? onPressed;
  final EdgeInsets? margin;
  final Widget child;

  StylizedButton._(this._type, {
    Key? key,
    this.colored = false,
    this.margin,
    this.onPressed,
    required this.child,
  }) : super(key: key);

  factory StylizedButton.raised({
    Key? key,
    bool colored = false,
    EdgeInsets? margin,
    VoidCallback? onPressed,
    required Widget child,
  }) {
    return StylizedButton._(
      _Type.raised,
      key: key,
      colored: colored,
      margin: margin,
      onPressed: onPressed,
      child: child,
    );
  }

  factory StylizedButton.outline({
    Key? key,
    bool colored = false,
    EdgeInsets? margin,
    VoidCallback? onPressed,
    required Widget child,
  }) {
    return StylizedButton._(
      _Type.outline,
      key: key,
      colored: colored,
      margin: margin,
      onPressed: onPressed,
      child: child,
    );
  }

  factory StylizedButton.flat({
    Key? key,
    bool colored = false,
    EdgeInsets? margin,
    VoidCallback? onPressed,
    required Widget child,
  }) {
    return StylizedButton._(
      _Type.flat,
      key: key,
      colored: colored,
      margin: margin,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(2);
    final color = context.brand.theme.colors.buttonBackground;
    final shadeColor = context.brand.theme.colors.buttonShade;

    final disabled = onPressed == null;

    Color textColor;
    if (disabled) {
      textColor = const Color(0xFF555555);
    }
    if (_type == _Type.raised) {
      textColor = colored
          ? context.brand.theme.colors.raisedColoredButtonText
          : Theme
          .of(context)
          .primaryColorDark;
    } else {
      textColor = colored ? Theme
          .of(context)
          .primaryColor : Colors.white;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: borderRadius,
    );

    final isRaised = _type == _Type.raised;
    final isOutline = _type == _Type.outline;
    final isFlat = _type == _Type.flat;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,
        decoration: BoxDecoration(
          boxShadow: [
            if (!disabled && isRaised)
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            decoration: BoxDecoration(
              // Always draw a border to avoid size differences between other
              // types
              border: isOutline
                  ? Border.all(
                color: colored ? color : Colors.white,
                width: _borderWidth,
              )
                  : null,
              borderRadius: shape.borderRadius,
              color: disabled
                  ? const Color(0xFFF5F5F5)
                  : isRaised
                  ? (colored ? color : Colors.white)
                  : Colors.transparent,
            ),
            child: CustomPaint(
              painter: _BottomBorderPainter(
                enabled: !isFlat,
                thickness: isRaised
                    ? _bottomBorderWidth
                    : _bottomBorderWidth - _borderWidth,
                color: isOutline
                    ? (colored ? color : Colors.white)
                    : (colored ? shadeColor : const Color(0xFFE0E0E0)),
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
                      child: AnimatedTheme(
                        duration: _duration,
                        curve: _curve,
                        data: Theme.of(context).copyWith(
                          iconTheme: IconThemeData(color: textColor),
                        ),
                        child: AnimatedDefaultTextStyle(
                          duration: _duration,
                          curve: _curve,
                          style: TextStyle(
                            color: textColor,
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
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (enabled) {
      canvas.drawRect(
        Rect.fromPoints(
          Offset(-2, size.height - thickness),
          Offset(size.width + 2, size.height + thickness),
        ),
        Paint()
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_BottomBorderPainter oldDelegate) =>
      color != oldDelegate.color || thickness != oldDelegate.thickness;
}
