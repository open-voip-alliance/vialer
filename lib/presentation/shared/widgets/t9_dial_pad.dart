import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vialer/presentation/resources/localizations.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/shared/controllers/dial_pad/riverpod.dart';
import 'package:vialer/presentation/shared/controllers/dial_pad/state.dart';
import 'package:vialer/presentation/shared/widgets/suggestion_chip.dart';

import '../../features/call/widgets/call_button.dart';
import '../../features/dialer/widgets/t9/widget.dart';
import 'dial_pad/keypad.dart';
import 'dial_pad/widget.dart';
import 'transparent_status_bar.dart';

class T9DialPad extends ConsumerStatefulWidget {
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
  ConsumerState<T9DialPad> createState() => _T9DialPadState();
}

class _T9DialPadState extends ConsumerState<T9DialPad>
    with WidgetsBindingObserver {
  late final TextEditingController controller;
  bool _phoneNumberSuggestionChipEnabled = true;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();

    controller.addListener(_disablePhoneNumberSuggestionChip);

    WidgetsBinding.instance
      ..addObserver(this)
      ..addPostFrameCallback((_) {
        _hasPhoneNumberFromClipboard();
      });
  }

  @override
  void dispose() {
    controller.removeListener(_disablePhoneNumberSuggestionChip);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _resetPhoneNumberSuggestionChipAfterResume(state);
  }

  void _disablePhoneNumberSuggestionChip() {
    if (_phoneNumberSuggestionChipEnabled) {
      setState(() {
        _phoneNumberSuggestionChipEnabled = false;
      });
    }
  }

  void _resetPhoneNumberSuggestionChipAfterResume(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && controller.text.isEmpty) {
      setState(() {
        _phoneNumberSuggestionChipEnabled = true;
      });

      _hasPhoneNumberFromClipboard();
    }
  }

  void _selectPhoneNumberSuggestionChip() {
    ref.read(clipboardProvider.notifier).getPhoneNumberFromClipboard();

    if (_phoneNumberSuggestionChipEnabled) {
      setState(() {
        _phoneNumberSuggestionChipEnabled = false;
      });
    }
  }

  Future<void> _hasPhoneNumberFromClipboard() async {
    ref.read(clipboardProvider.notifier).hasPhoneNumberFromClipboard();
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
    final _clipboardState = ref.watch(clipboardProvider);
    final _shouldShowPhoneNumberSuggestionChip =
        _phoneNumberSuggestionChipEnabled && _clipboardState is HasPhoneNumber;

    ref.listen<ClipboardState>(clipboardProvider, (
      ClipboardState? previousState,
      ClipboardState newState,
    ) {
      if (newState is Success) {
        controller.text = newState.number;
      }
    });

    return TransparentStatusBar(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            if (widget.isT9ContactSearchEnabled) ...[
              Stack(
                children: [
                  T9ColltactsListView(controller: controller),
                  if (_shouldShowPhoneNumberSuggestionChip) ...[
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.center,
                        child: _PhoneNumberSuggestionChip(
                          onSelected: _selectPhoneNumberSuggestionChip,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
            ] else ...[
              SafeArea(
                child: SizedBox(
                  height: (_shouldShowPhoneNumberSuggestionChip) ? 0 : 58,
                ),
              ),
              if (_shouldShowPhoneNumberSuggestionChip) ...[
                _PhoneNumberSuggestionChip(
                  onSelected: _selectPhoneNumberSuggestionChip,
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ],
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

class _PhoneNumberSuggestionChip extends StatelessWidget {
  final VoidCallback onSelected;

  _PhoneNumberSuggestionChip({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SuggestionChip(
      icon: FontAwesomeIcons.paste,
      label: context.msg.main.dialer.clipboard.copyPhoneNumber.title,
      onSelected: onSelected,
    );
  }
}
