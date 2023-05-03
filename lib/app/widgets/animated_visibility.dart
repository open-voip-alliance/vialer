import 'package:flutter/material.dart';

class AnimatedVisibility extends StatefulWidget {
  const AnimatedVisibility({
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.decelerate,
    super.key,
  });

  final bool visible;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  State<AnimatedVisibility> createState() => _AnimatedVisibilityState();
}

class _AnimatedVisibilityState extends State<AnimatedVisibility> {
  // Not called 'visible' since that can be confused with `widget.visible`.
  bool _visibilityEnabled = false;

  @override
  void initState() {
    super.initState();

    _visibilityEnabled = widget.visible;
  }

  @override
  void didUpdateWidget(covariant AnimatedVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.visible != widget.visible && widget.visible) {
      _visibilityEnabled = true;
    }
  }

  void _onAnimationEnd() {
    if (!widget.visible) {
      setState(() {
        _visibilityEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Improve animation to not be staggered whe
    // going from visible to invisible.
    return AnimatedSize(
      curve: widget.curve,
      duration: widget.duration,
      child: AnimatedOpacity(
        curve: widget.curve,
        duration: widget.duration,
        opacity: widget.visible ? 1 : 0,
        onEnd: _onAnimationEnd,
        child: Visibility(
          visible: _visibilityEnabled,
          child: widget.child,
        ),
      ),
    );
  }
}
