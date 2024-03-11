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
  bool _suggestionChipEnabled = true;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    // Add a listener to the controller to observe text changes
    controller.addListener(_observeTextChanges);
    // Add a observer to the widget binding to observe app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // Check if there is a number in the clipboard after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasNumberFromClipboard();
    });
  }

  void _observeTextChanges() {
    // Disable the paste button if the user is typing
    if (_suggestionChipEnabled) {
      setState(() {
        _suggestionChipEnabled = false;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_observeTextChanges);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check if the app is resumed and the textdield empty to reset paste clipboard state
    if (state == AppLifecycleState.resumed && controller.text.isEmpty) {
      setState(() {
        _suggestionChipEnabled = true;
      });

      _hasNumberFromClipboard();
    }
  }

  Future<void> _hasNumberFromClipboard() async {
    ref.read(clipboardProvider.notifier).hasNumberFromClipboard();
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
    final _shouldShowSuggestionChip =
        _suggestionChipEnabled && _clipboardState is HasNumber;

    /// Listens to changes in the [ClipboardState] and updates the [controller.text]
    /// with the new number if the [ClipboardState] is [Success].
    ref.listen<ClipboardState>(clipboardProvider,
        (ClipboardState? previousState, ClipboardState newState) {
      if (newState is Success) {
        controller.text = newState.number;
      }
    });

    /// Builds a suggestion chip widget.
    ///
    /// This method returns a [SuggestionChip] widget that displays an icon and a label.
    /// The icon is a [FaIcon] with the FontAwesomeIcons.paste icon, and the label is
    /// retrieved from the context's message property.
    /// When the chip is selected, it calls the [getNumberFromClipboard] method from the
    /// [clipboardProvider] notifier, and updates the [pasteClipboardEnabled] state if
    /// necessary.
    SuggestionChip _buildSuggestionChip() {
      return SuggestionChip(
        icon: FaIcon(
          FontAwesomeIcons.paste,
          size: 18,
          color: Theme.of(context).primaryColor,
        ),
        label: context.msg.main.dialer.clipboard.copyPhoneNumber.title,
        onSelected: () {
          ref.read(clipboardProvider.notifier).getNumberFromClipboard();

          if (_suggestionChipEnabled) {
            setState(() {
              _suggestionChipEnabled = false;
            });
          }
        },
      );
    }

    return TransparentStatusBar(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            if (widget.isT9ContactSearchEnabled) ...[
              Stack(children: [
                T9ColltactsListView(controller: controller),
                if (_shouldShowSuggestionChip) ...[
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildSuggestionChip(),
                    ),
                  ),
                ]
              ]),
              const Divider(
                height: 1,
                thickness: 1,
              ),
            ] else ...[
              SafeArea(
                child: SizedBox(
                  height: (_shouldShowSuggestionChip) ? 0 : 58,
                ),
              ),
              if (_shouldShowSuggestionChip) ...[
                _buildSuggestionChip(),
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
