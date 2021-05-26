import 'package:flutter/material.dart';

import '../../../resources/theme.dart';
import '../../../widgets/transparent_status_bar.dart';
import '../call/widgets/call_button.dart';
import '../dialer/widgets/t9/widget.dart';
import 'dial_pad/keypad.dart';
import 'dial_pad/widget.dart';

class T9DialPad extends StatefulWidget {
  /// The [number] that the user is attempting to make a call to.
  final void Function(String number) onCallButtonPressed;
  final IconData callButtonIcon;
  final Color callButtonColor;
  final TextEditingController? controller;
  final VoidCallback? onDeleteAll;

  const T9DialPad({
    required this.onCallButtonPressed,
    required this.callButtonIcon,
    required this.callButtonColor,
    this.controller,
    this.onDeleteAll,
  });

  @override
  _T9DialPadState createState() => _T9DialPadState();
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

    widget.onCallButtonPressed(number);

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return TransparentStatusBar(
      brightness: Brightness.dark,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            if (context.isAndroid) ...[
              T9ContactsListView(controller: controller),
              const Divider(
                height: 1,
                thickness: 1,
              ),
            ] else if (context.isIOS)
              const SafeArea(
                child: SizedBox(
                  height: 48,
                ),
              ),
            Expanded(
              child: DialPad(
                controller: controller,
                primaryButton: _DialerPrimaryButton(
                  onPressed: () => _call(context),
                  icon: widget.callButtonIcon,
                  color: widget.callButtonColor,
                ),
                onDeleteAll: widget.onDeleteAll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialerPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  const _DialerPrimaryButton({
    Key? key,
    this.onPressed,
    required this.icon,
    required this.color,
  }) : super(key: key);

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
        backgroundColor: color,
        icon: icon,
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
      ),
    );
  }
}
