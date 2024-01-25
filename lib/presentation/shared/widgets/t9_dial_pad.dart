import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/theme.dart';

import '../../features/call/widgets/call_button.dart';
import '../../features/dialer/widgets/t9/widget.dart';
import 'dial_pad/keypad.dart';
import 'dial_pad/widget.dart';
import 'transparent_status_bar.dart';

class T9DialPad extends StatefulWidget {
  const T9DialPad({
    required this.onCallButtonPressed,
    required this.callButtonIcon,
    required this.callButtonColor,
    required this.callButtonSemanticsHint,
    this.controller,
    this.onDeleteAll,
    this.bottomLeftButton,
    this.bottomRightButton,
    this.isT9ContactSearchEnabled = true,
    super.key,
  });

  final void Function(String number)? onCallButtonPressed;
  final IconData callButtonIcon;
  final Color callButtonColor;
  final String callButtonSemanticsHint;
  final TextEditingController? controller;
  final VoidCallback? onDeleteAll;

  final Widget? bottomLeftButton;
  final Widget? bottomRightButton;

  final bool isT9ContactSearchEnabled;

  @override
  State<T9DialPad> createState() => _T9DialPadState();
}

class _T9DialPadState extends State<T9DialPad> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
  }

  void _call(BuildContext context) {
    final number = controller.text;

    assert(
      widget.onCallButtonPressed != null,
      'Attempting to call when onCallButtonPressed was null',
    );

    widget.onCallButtonPressed?.call(number);

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TransparentStatusBar(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            if (widget.isT9ContactSearchEnabled) ...[
              T9ColltactsListView(controller: controller),
              const Divider(
                height: 1,
                thickness: 1,
              ),
            ] else
              const SafeArea(
                child: SizedBox(
                  height: 48,
                ),
              ),
            Expanded(
              child: DialPad(
                controller: controller,
                bottomCenterButton: _DialerPrimaryButton(
                  onPressed: widget.onCallButtonPressed != null
                      ? () => _call(context)
                      : null,
                  icon: widget.callButtonIcon,
                  color: widget.callButtonColor,
                  semanticsHint: widget.callButtonSemanticsHint,
                ),
                onDeleteAll: widget.onDeleteAll,
                bottomLeftButton: widget.bottomLeftButton,
                bottomRightButton: widget.bottomRightButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialerPrimaryButton extends StatelessWidget {
  const _DialerPrimaryButton({
    required this.icon,
    required this.color,
    required this.semanticsHint,
    this.onPressed,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final String semanticsHint;

  @override
  Widget build(BuildContext context) {
    // On iOS we want the call button to be the same size as the
    // other buttons. Even though we set the max size as the min size,
    // a ConstrainedBox will never impose impossible constraints, so it's not
    // a problem. In this case, it basically means: 'Biggest size possible, but
    // with a certain limit'.
    final minSize = context.isIOS ? KeypadValueButton.maxSize : 64.0;

    return Center(
      child: CallButton(
        onPressed: onPressed,
        backgroundColor:
            onPressed != null ? color : context.brand.theme.colors.grey3,
        icon: icon,
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        semanticsHint: semanticsHint,
      ),
    );
  }
}
