import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/theme.dart';
import '../../../../widgets/connectivity_checker.dart';
import 'key_input.dart';
import 'keypad.dart';

class DialPad extends StatefulWidget {
  final TextEditingController controller;

  /// Whether input can be deleted with the delete button. If false, the
  /// delete button will stay greyed-out, even if input is present.
  final bool canDelete;

  /// Called when the delete button has been long-pressed, and all input is
  /// deleted.
  final VoidCallback? onDeleteAll;

  final Widget? bottomLeftButton;
  final Widget bottomCenterButton;
  final Widget? bottomRightButton;

  const DialPad({
    Key? key,
    required this.controller,
    this.onDeleteAll,
    this.canDelete = true,
    this.bottomLeftButton,
    required this.bottomCenterButton,
    this.bottomRightButton,
  }) : super(key: key);

  @override
  State<DialPad> createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  /// This is necessary to keep track of because if the cursor has been shown
  /// once in a readOnly text field, the cursor will be shown forever, even if
  /// the offset is reported as -1. We need to update the position of the
  /// cursor in that case.
  final _cursorShownNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          child: KeyInput(
            controller: widget.controller,
            cursorShownNotifier: _cursorShownNotifier,
            canDelete: widget.canDelete,
            onDeleteAll: widget.onDeleteAll,
          ),
        ),
        if (context.isIOS) const SizedBox(height: 24),
        Flexible(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child:
                      BlocBuilder<ConnectivityCheckerCubit, ConnectivityState>(
                    builder: (context, state) {
                      return Keypad(
                        controller: widget.controller,
                        cursorShownNotifier: _cursorShownNotifier,
                        constraints: constraints,
                        bottomCenterButton: widget.bottomCenterButton,
                        bottomLeftButton: widget.bottomLeftButton,
                        bottomRightButton: widget.bottomRightButton,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
