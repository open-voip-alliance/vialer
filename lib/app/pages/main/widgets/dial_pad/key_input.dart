import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../../../resources/localizations.dart';
import '../../../../resources/theme.dart';

class KeyInput extends StatefulWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;
  final bool canDelete;
  final VoidCallback? onDeleteAll;

  const KeyInput({
    Key? key,
    required this.controller,
    required this.cursorShownNotifier,
    this.canDelete = true,
    this.onDeleteAll,
  }) : super(key: key);

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
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const deleteButtonPadding = 24.0;

    return TextField(
      controller: widget.controller,
      scrollController: _scrollController,
      // This is needed so that the keyboard doesn't popup. We can't use
      // readOnly because then pasting is not allowed.
      focusNode: _NeverFocusNode(),
      inputFormatters: [_KeyInputFormatter()],
      showCursor: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: context.brand.theme.colors.grey3.withOpacity(0.5),
        contentPadding: const EdgeInsets.only(
          left: _DeleteButton.size + deleteButtonPadding + 12,
          top: 8,
          right: 12,
          bottom: 8,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: deleteButtonPadding),
          child: _DeleteButton(
            controller: widget.controller,
            cursorShownNotifier: widget.cursorShownNotifier,
            canDelete: widget.canDelete,
            onDeleteAll: widget.onDeleteAll,
          ),
        ),
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputChanged);
    super.dispose();
  }
}

class _NeverFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

/// Removes all characters not generally allowed in a phone number.
class _KeyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.replaceAll(RegExp(r'[^0-9^+^,^;^(^)^.^-]'), ''),
    );
  }
}

class _DeleteButton extends StatefulWidget {
  final TextEditingController controller;
  final ValueNotifier<bool> cursorShownNotifier;
  final bool canDelete;
  final VoidCallback? onDeleteAll;

  static const double size = 32;

  const _DeleteButton({
    Key? key,
    required this.controller,
    required this.cursorShownNotifier,
    this.canDelete = true,
    this.onDeleteAll,
  }) : super(key: key);

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

      SemanticsService.announce(
        context.msg.main.dialer.button.delete.deletedHint(
          deleted,
          deleted.characters.length,
        ),
        Directionality.of(context),
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
      SemanticsService.announce(
        context.msg.main.dialer.button.delete.deletedHint(digits, digitCount),
        Directionality.of(context),
      );
    } else {
      SemanticsService.announce(
        context.msg.main.dialer.button.delete.deletedAllHint,
        Directionality.of(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: context.msg.main.dialer.button.delete.hint,
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
          child: const Icon(
            VialerSans.correct,
            size: _DeleteButton.size,
          ),
        ),
      ),
    );
  }
}
