import 'package:flutter/material.dart';

typedef ParentWidgetBuilder = Widget Function(Widget child);

class NestedChildren extends StatelessWidget {
  final List<ParentWidgetBuilder> children;
  final Widget lastChild;

  NestedChildren(this.children, this.lastChild) : assert(children.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return children.reversed.fold(
      lastChild,
      (child, builder) => builder(child),
    );
  }
}
