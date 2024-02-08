import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';

class CallButton extends StatelessWidget {
  const CallButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.semanticsHint,
    this.heroTag = defaultHeroTag,
    this.constraints = defaultConstraints,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color backgroundColor;
  final IconData icon;
  final Object? heroTag;
  final BoxConstraints constraints;
  final String semanticsHint;

  static const defaultHeroTag = _DefaultCallButtonHeroTag();
  static const defaultConstraints = BoxConstraints.tightFor(
    width: 64,
    height: 64,
  );

  static Widget answer({
    Key? key,
    VoidCallback? onPressed,
    Object? heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
    String? semanticsHint,
  }) {
    return Builder(
      builder: (context) {
        return CallButton(
          onPressed: onPressed,
          backgroundColor: context.brand.theme.colors.green1,
          icon: FontAwesomeIcons.solidPhone,
          heroTag: heroTag,
          constraints: constraints,
          semanticsHint: semanticsHint ?? context.msg.main.call.incoming.answer,
        );
      },
    );
  }

  static Widget decline({
    Key? key,
    VoidCallback? onPressed,
    Object? heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
    String? semanticsHint,
  }) {
    return Builder(
      builder: (context) {
        return CallButton(
          onPressed: onPressed,
          backgroundColor: context.brand.theme.colors.red1,
          icon: FontAwesomeIcons.solidPhoneHangup,
          heroTag: heroTag,
          constraints: constraints,
          semanticsHint:
              semanticsHint ?? context.msg.main.call.incoming.decline,
        );
      },
    );
  }

  static Widget call({
    Key? key,
    VoidCallback? onPressed,
    Object? heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
    String? semanticsHint,
  }) {
    return Builder(
      builder: (context) {
        return answer(
          key: key,
          onPressed: onPressed,
          heroTag: heroTag,
          constraints: constraints,
          semanticsHint: semanticsHint ?? context.msg.generic.button.call,
        );
      },
    );
  }

  static Widget hangUp({
    Key? key,
    VoidCallback? onPressed,
    Object? heroTag = defaultHeroTag,
    BoxConstraints constraints = defaultConstraints,
    String? semanticsHint,
  }) {
    return Builder(
      builder: (context) {
        return decline(
          key: key,
          onPressed: onPressed,
          heroTag: heroTag,
          constraints: constraints,
          semanticsHint: semanticsHint ?? context.msg.main.call.ongoing.hangUp,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints,
      child: MergeSemantics(
        child: Semantics(
          // TODO? Use onTapHint when the screen reader doesn't announce it
          // as if it's a custom action. Maybe a Flutter issue, maybe not.
          hint: semanticsHint,
          child: FloatingActionButton(
            heroTag: heroTag,
            onPressed: onPressed,
            backgroundColor: onPressed != null
                ? backgroundColor
                : context.brand.theme.colors.grey3,
            child: FaIcon(
              icon,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultCallButtonHeroTag {
  const _DefaultCallButtonHeroTag();
}
