import 'package:flutter/widgets.dart';

/// A [Row] that forces all [children] to be expanded vertically to fill the
/// entire height of the Row (the height of the tallest child). This is useful
/// if you need buttons to have larger touch targets.
class VerticallyExpandedRow extends StatelessWidget {
  const VerticallyExpandedRow({super.key, this.children = const []});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
