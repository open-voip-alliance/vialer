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
