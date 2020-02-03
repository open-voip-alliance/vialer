import 'package:flutter/material.dart';

class StylizedRaisedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  StylizedRaisedButton({Key key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      color: Colors.white,
      child: _Text(text),
    );
  }
}

class StylizedOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  StylizedOutlineButton({Key key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onPressed,
      color: Colors.white,
      child: _Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      borderSide: BorderSide(
        width: 1,
        color: Colors.white,
      ),
      highlightedBorderColor: Colors.white,
    );
  }
}

class StylizedFlatButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  StylizedFlatButton({Key key, this.text, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: _Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _Text extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _Text(
    this.text, {
    Key key,
    this.style = const TextStyle(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      Theme.of(context).platform == TargetPlatform.android
          ? text.toUpperCase()
          : text,
      style: style.copyWith(
        fontWeight: Theme.of(context).platform == TargetPlatform.iOS
            ? FontWeight.bold
            : null,
        fontSize: Theme.of(context).platform == TargetPlatform.iOS ? 16 : null,
      ),
    );
  }
}
