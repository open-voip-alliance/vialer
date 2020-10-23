import 'package:flutter/material.dart';

/// Will show the [placeholder] if [showPlaceholder] is true,
/// else it will show the [child].
class ConditionalPlaceholder extends StatelessWidget {
  final bool showPlaceholder;
  final Widget placeholder;
  final Widget child;

  const ConditionalPlaceholder({
    Key key,
    @required this.showPlaceholder,
    @required this.placeholder,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return showPlaceholder ? placeholder : child;
  }
}

class Warning extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget description;
  final List<Widget> children;

  const Warning({
    Key key,
    @required this.icon,
    @required this.title,
    @required this.description,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 64,
          right: 64,
          top: 84,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _Illustration(
              child: icon,
            ),
            SizedBox(height: 20),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              child: title,
            ),
            SizedBox(height: 16),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              child: description,
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final Widget title;
  final Widget description;

  const LoadingIndicator({
    Key key,
    this.title,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Warning(
      icon: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).primaryColor,
          ),
          strokeWidth: 6,
        ),
      ),
      title: title,
      description: description,
    );
  }
}

class _Illustration extends StatelessWidget {
  final Widget child;

  const _Illustration({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    const borderWidth = 20.0;
    const padding = 24.0;
    final backgroundColor = Theme.of(context).primaryColorLight;

    return Container(
      width: size + padding + borderWidth,
      height: size + padding + borderWidth,
      padding: const EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.40),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: IconTheme(
          data: IconTheme.of(context).copyWith(
            color: Theme.of(context).primaryColor,
            size: 48,
          ),
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
