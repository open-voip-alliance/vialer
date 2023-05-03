import 'package:flutter/material.dart';

/// It is only possible to use the default [RefreshIndicator] with a [ListView],
/// this will wrap the provided [child] so it can also have drag-to-refresh
/// functionality.
class UniversalRefreshIndicator extends StatelessWidget {
  const UniversalRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Slightly hacky method of ensuring the child widget is aligned properly,
    // composed based on responses in the following thread:
    // https://stackoverflow.com/questions/54051121/flutter-no-refresh-indicator-when-using-refreshindicator
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Stack(
        children: [
          child,
          ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
