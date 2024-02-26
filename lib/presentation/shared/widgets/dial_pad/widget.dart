import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vialer/presentation/resources/theme.dart';
import 'package:vialer/presentation/shared/controllers/dial_pad/riverpod.dart';
import 'package:vialer/presentation/shared/controllers/dial_pad/state.dart';
import '../../controllers/connectivity_checker/cubit.dart';
import 'key_input.dart';
import 'keypad.dart';

class DialPad extends ConsumerStatefulWidget {
  const DialPad({
    required this.controller,
    required this.bottomCenterButton,
    this.bottomLeftButton,
    this.bottomRightButton,
    this.onDeleteAll,
    this.canDelete = true,
    super.key,
  });

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

  @override
  ConsumerState<DialPad> createState() => _DialPadState();
}

class _DialPadState extends ConsumerState<DialPad> {
  /// This is necessary to keep track of because if the cursor has been shown
  /// once in a readOnly text field, the cursor will be shown forever, even if
  /// the offset is reported as -1. We need to update the position of the
  /// cursor in that case.
  final _cursorShownNotifier = ValueNotifier<bool>(false);
  final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();
  String clipboardData = '';
  Timer? clipboardPollingTimer;
  bool showTooltip = true;

  @override
  void initState() {
    super.initState();

    clipboardPollingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _getClipboardData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getClipboardData();
    });
  }

  Future<void> _getClipboardData() async {
    ref.read(clipboardProvider.notifier).getNumberFromClipboard();
  }

  @override
  void dispose() {
    clipboardPollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clipboardState = ref.watch(clipboardProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          child: Column(children: [
            KeyInput(
              controller: widget.controller,
              cursorShownNotifier: _cursorShownNotifier,
              canDelete: widget.canDelete,
              onDeleteAll: widget.onDeleteAll,
            ),
            if (showTooltip && clipboardState is Success)
              ClipboardTooltip(
                clipboardData: clipboardState.number,
                onClose: () {
                  setState(() {
                    showTooltip = false;
                  });
                },
                onTap: () {
                  widget.controller.text = clipboardData;
                  setState(() {
                    showTooltip = false;
                  });
                },
              )
          ]),
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

class ClipboardTooltip extends StatelessWidget {
  final String clipboardData;
  final VoidCallback onClose;
  final VoidCallback onTap;

  ClipboardTooltip({
    required this.clipboardData,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            IntrinsicWidth(
              child: Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(clipboardData, style: TextStyle(color: Colors.white)),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: onClose,
                        child: Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -10,
              child: Icon(Icons.arrow_drop_up, color: Colors.blue, size: 52.0),
            ),
          ],
        ),
      ),
    );
  }
}
