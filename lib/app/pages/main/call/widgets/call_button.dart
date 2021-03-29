import 'package:flutter/material.dart';

import '../../../../resources/theme.dart';
import '../../../../util/brand.dart';

class CallButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Object heroTag;
  final BoxConstraints constraints;

  static const defaultHeroTag = _DefaultCallButtonHeroTag();
  static const defaultConstraints = BoxConstraints.tightFor(
    width: 64,
    height: 64,
  );

  const CallButton({
    Key key,
    @required this.onPressed,
    @required this.backgroundColor,
    @required this.icon,
    this.heroTag = defaultHeroTag,
    this.constraints = defaultConstraints,
  }) : super(key: key);

  static Widget answer({
    Key key,
    @required VoidCallback onPressed,
    Object heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
  }) {
    return Builder(
      builder: (context) {
        return CallButton(
          onPressed: onPressed,
          backgroundColor: context.brand.theme.green1,
          icon: VialerSans.phone,
          heroTag: heroTag,
          constraints: constraints,
        );
      },
    );
  }

  static Widget decline({
    Key key,
    @required VoidCallback onPressed,
    Object heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
  }) {
    return Builder(
      builder: (context) {
        return CallButton(
          onPressed: onPressed,
          backgroundColor: context.brand.theme.red1,
          icon: VialerSans.hangUp,
          heroTag: heroTag,
          constraints: constraints,
        );
      },
    );
  }

  // Different names for different contexts.

  static Widget call({
    Key key,
    @required VoidCallback onPressed,
    Object heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
  }) =>
      answer(
        key: key,
        onPressed: onPressed,
        heroTag: heroTag,
        constraints: constraints,
      );

  static Widget hangUp({
    Key key,
    @required VoidCallback onPressed,
    Object heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
  }) =>
      decline(
        key: key,
        onPressed: onPressed,
        heroTag: heroTag,
        constraints: constraints,
      );

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor:
            onPressed != null ? backgroundColor : context.brand.theme.grey3,
        child: Icon(
          icon,
          size: 32,
        ),
      ),
    );
  }
}

class _DefaultCallButtonHeroTag {
  const _DefaultCallButtonHeroTag();
}
