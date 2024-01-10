import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/app/pages/main/util/phone_number.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class KeyInput extends StatefulWidget {
  const KeyInput({
    required this.controller,
    required this.cursorShownNotifier,
    this.canDelete = true,
    this.onDeleteAll,
    super.key,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;
  final bool canDelete;
  final VoidCallback? onDeleteAll;

  @override
  State<KeyInput> createState() => _KeyInputState();
}

class _KeyInputState extends State<KeyInput> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    // Scroll to the end when a character is inserted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
      );
    });

    // We need to make sure the semantics label updates so we're always going to
    // trigger a rebuild when the number is updated.
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    const deleteButtonPadding = 24.0;

    return Container(
      color: context.brand.theme.colors.grey3.withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              excludeSemantics: true,
              container: true,
              blockUserActions: context.isUsingScreenReader,
              label: widget.controller.text.isEmpty
                  ? context.msg.main.dialer.screenReader.phoneNumberInput
                  : context.msg.main.dialer.screenReader
                      .phoneNumberInputPopulated(
                      widget.controller.text.phoneNumberSemanticLabel,
                    ),
              child: PlatformTextField(
                controller: widget.controller,
                scrollController: _scrollController,
                inputFormatters: [_KeyInputFormatter()],
                showCursor: false,
                keyboardType: TextInputType.none,
                enableInteractiveSelection: !context.isUsingScreenReader,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32),
                material: (_, __) => MaterialTextFieldData(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.only(
                      left: _DeleteButton.size + deleteButtonPadding + 12,
                      top: 8,
                      right: 12,
                      bottom: 8,
                    ),
                  ),
                ),
                cupertino: (_, __) => CupertinoTextFieldData(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0,
                      color: Colors.transparent,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: _DeleteButton.size + deleteButtonPadding + 12,
                    top: 8,
                    right: 12,
                    bottom: 8,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: deleteButtonPadding),
            child: _DeleteButton(
              controller: widget.controller,
              cursorShownNotifier: widget.cursorShownNotifier,
              canDelete: widget.canDelete,
              onDeleteAll: widget.onDeleteAll,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputChanged);
    super.dispose();
  }
}

/// Removes all characters not generally allowed in a phone number.
class _KeyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.replaceAll(RegExp('[^0-9^+^,^;^(^)^.^-]'), ''),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  const _DeleteButton({
    required this.controller,
    required this.cursorShownNotifier,
    this.canDelete = true,
    this.onDeleteAll,
  });

  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;
  final bool canDelete;
  final VoidCallback? onDeleteAll;

  static const double size = 32;

  @override
  State<StatefulWidget> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton> {
  TextEditingController get _controller => widget.controller;

  bool __canDelete = false;

  bool get _canDelete => widget.canDelete && __canDelete;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_handleStatusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStatusChange);

    super.dispose();
  }

  void _handleStatusChange() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        __canDelete = true;
      });
    } else {
      setState(() {
        __canDelete = false;
      });
    }
  }

  void _delete() {
    if (_controller.text.isNotEmpty) {
      final baseOffset = _controller.selection.baseOffset;
      final extentOffset = _controller.selection.extentOffset;

      if (baseOffset == 0 && extentOffset == 0) {
        return;
      }

      final hasOffset = baseOffset >= 0 && extentOffset >= 0;

      final text = _controller.text;

      final cursorShown = widget.cursorShownNotifier.value;

      String start, end, deleted;
      if (hasOffset) {
        final startOffset =
            baseOffset == extentOffset ? baseOffset - 1 : baseOffset;
        start = text.substring(
          0,
          startOffset,
        );
        end = text.substring(extentOffset);
        deleted = text.substring(startOffset, extentOffset);
      } else {
        start = text.substring(0, text.length - 1);
        end = '';
        deleted = text.characters.last;
      }

      widget.controller.value = _controller.value.copyWith(
        text: start + end,
        selection: TextSelection.collapsed(
          offset: hasOffset || cursorShown
              ? baseOffset == extentOffset
                  ? baseOffset - 1
                  : baseOffset
              : -1,
        ),
      );

      unawaited(
        SemanticsService.announce(
          context.msg.main.dialer.button.delete.deletedHint(
            deleted,
            deleted.characters.length,
          ),
          Directionality.of(context),
        ),
      );
    }
  }

  void _deleteAll() {
    final digits = _controller.text;
    final digitCount = digits.characters.length;
    final deletedSingleDigit = digitCount == 1;

    _controller.clear();
    widget.onDeleteAll?.call();

    // We don't want to announce anything on iOS, because on iOS the label is
    // (unfortunately) always read out after a tap, meaning our manual
    // announcements are not read at best, or interfering with the label
    // announcement at worst.
    if (context.isIOS) return;

    // We say the digit out loud when deleting a single digit, to mimic
    // the native dialer.
    if (deletedSingleDigit) {
      unawaited(
        SemanticsService.announce(
          context.msg.main.dialer.button.delete.deletedHint(digits, digitCount),
          Directionality.of(context),
        ),
      );
    } else {
      unawaited(
        SemanticsService.announce(
          context.msg.main.dialer.button.delete.deletedAllHint,
          Directionality.of(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: context.msg.main.dialer.button.delete.hint,
      onTap: _delete,
      onLongPress: _deleteAll,
      excludeSemantics: true,
      child: InkResponse(
        onTap: _canDelete ? _delete : null,
        onLongPress: _canDelete ? _deleteAll : null,
        child: AnimatedTheme(
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  color: _canDelete
                      ? context.brand.theme.colors.grey5
                      : context.brand.theme.colors.grey2,
                ),
          ),
          // Must stay as `Icon` (used in a `TextField`).
          child: const Icon(
            FontAwesomeIcons.deleteLeft,
            size: _DeleteButton.size,
          ),
        ),
      ),
    );
  }
}

extension Accessibility on BuildContext {
  bool get isUsingScreenReader => MediaQuery.of(this).accessibleNavigation;
}
