import 'package:flutter/material.dart';

class ColoredButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  final _Type _type;

  const ColoredButton._({
    Key key,
    @required _Type type,
    @required this.onPressed,
    @required this.child,
  })  : _type = type,
        super(key: key);

  factory ColoredButton.filled({
    Key key,
    @required VoidCallback onPressed,
    @required Widget child,
  }) {
    return ColoredButton._(
      type: _Type.filled,
      onPressed: onPressed,
      child: child,
    );
  }

  factory ColoredButton.outline({
    Key key,
    @required VoidCallback onPressed,
    @required Widget child,
  }) {
    return ColoredButton._(
      type: _Type.outline,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFilled = _type == _Type.filled;
    final isOutline = _type == _Type.outline;

    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: isFilled ? Theme.of(context).primaryColorLight : null,
      elevation: 0,
      disabledElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      hoverElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: isOutline ? BorderSide(
          color: Theme.of(context).primaryColorLight,
        ) : BorderSide.none,
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontWeight: FontWeight.bold,
        ),
        child: child,
      ),
    );
  }
}

enum _Type {
  filled,
  outline,
}
