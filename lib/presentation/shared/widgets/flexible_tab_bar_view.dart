import 'package:flutter/material.dart';

/// Wraps a [TabBarView] but if [children] is only a single element, will just
/// return it directly and skip the [TabBarView].
class FlexibleTabBarView extends StatelessWidget {
  const FlexibleTabBarView({
    required this.controller,
    required this.children,
    super.key,
  });

  final TabController? controller;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return Container();

    return children.length > 1
        ? TabBarView(controller: controller, children: children)
        : children.first;
  }
}
