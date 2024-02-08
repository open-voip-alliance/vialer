import 'package:flutter/material.dart';

typedef ParentWidgetBuilder = Widget Function(Widget child);

class MultiWidgetParent extends StatelessWidget {
  MultiWidgetParent(this.children, this.lastChild, {super.key})
      : assert(children.isNotEmpty, 'children must not be empty');

  final List<ParentWidgetBuilder> children;
  final Widget lastChild;

  @override
  Widget build(BuildContext context) {
    return children.reversed.fold(
      lastChild,
      (child, builder) => builder(child),
    );
  }
}

/// Wraps a [Builder] purely for semantic reasons. This is to allow children in
/// a [MultiWidgetParent] that require the context from previous builds to be
/// initialized.
class MultiWidgetChildWithDependencies extends StatelessWidget {
  const MultiWidgetChildWithDependencies({
    super.key,
    required this.builder,
  });

  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext _) {
    return Builder(
      builder: (context) {
        return builder(context);
      },
    );
  }
}
