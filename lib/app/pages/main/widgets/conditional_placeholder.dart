import 'package:flutter/material.dart';

/// Will show the [placeholder] if [showPlaceholder] is true,
/// else it will show the [child].
class ConditionalPlaceholder extends StatelessWidget {
  const ConditionalPlaceholder({
    required this.showPlaceholder,
    required this.placeholder,
    required this.child,
    super.key,
  });

  final bool showPlaceholder;
  final Widget placeholder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return showPlaceholder ? placeholder : child;
  }
}

class Warning extends StatelessWidget {
  const Warning({
    required this.icon,
    required this.title,
    required this.description,
    this.children = const [],
    super.key,
  });

  final Widget icon;
  final Widget title;
  final Widget description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 54,
          right: 54,
          top: 54,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Illustration(
              child: icon,
            ),
            const SizedBox(height: 20),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              child: title,
            ),
            const SizedBox(height: 16),
            DefaultTextStyle.merge(
              style: const TextStyle(
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
  const LoadingIndicator({
    required this.title,
    required this.description,
    super.key,
  });

  final Widget title;
  final Widget description;

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
  const _Illustration({required this.child});

  final Widget child;

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
        alignment: Alignment.center,
        child: IconTheme(
          data: IconTheme.of(context).copyWith(
            color: Theme.of(context).primaryColor,
            size: 42,
          ),
          child: child,
        ),
      ),
    );
  }
}
