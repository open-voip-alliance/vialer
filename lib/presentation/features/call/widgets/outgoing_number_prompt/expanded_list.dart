import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vialer/presentation/util/context_extensions.dart';

import '../../../../../../data/models/calling/outgoing_number/outgoing_number.dart';
import '../../../../../data/models/outgoing_number_prompt/outgoing_number_selection.dart';
import '../../../../resources/localizations.dart';
import '../../../../resources/messages.i18n.dart';
import 'heading.dart';
import 'item.dart';
import 'widget.dart';

class ExpandedList extends StatelessWidget {
  const ExpandedList(
    this.state, {
    required this.onOutgoingNumberSelected,
  });

  final OutgoingNumberSelectorState state;
  final OutgoingNumberSelectedCallback onOutgoingNumberSelected;

  void _showNumberSelectionDialog(BuildContext context) async {
    final outgoingNumber = await showDialog<OutgoingNumber>(
      context: context,
      builder: (_) => SimpleDialog(
        children: [
          Container(
            width: double.maxFinite,
            child: _AllNumbersSelectionDialog(
              state,
              (outgoingNumber) => Navigator.pop(
                context,
                outgoingNumber,
              ),
            ),
          ),
        ],
      ),
    );

    if (outgoingNumber != null) {
      onOutgoingNumberSelected(outgoingNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentOutgoingNumbers = state.recentOutgoingNumbers
        .filter((item) => item != state.currentOutgoingNumber);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (recentOutgoingNumbers.isNotEmpty) ...[
          Subheading(context.strings.recentlyUsedNumbers.label),
          ...recentOutgoingNumbers.toWidgets(
            onOutgoingNumberSelected,
            state.currentOutgoingNumber,
          ),
        ],
        Subheading(context.strings.allNumbers.label),
        _ButtonStylizedAsDropdown(
          onPressed: () => _showNumberSelectionDialog(context),
        ),
      ],
    );
  }
}

class _AllNumbersSelectionDialog extends StatefulWidget {
  const _AllNumbersSelectionDialog(this.state, this.onOutgoingNumberSelected);

  final OutgoingNumberSelectorState state;
  final OutgoingNumberSelectedCallback onOutgoingNumberSelected;

  @override
  State<_AllNumbersSelectionDialog> createState() =>
      _AllNumbersSelectionDialogState();
}

class _AllNumbersSelectionDialogState
    extends State<_AllNumbersSelectionDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var searchTerm = '';

  List<OutgoingNumber> get items => widget.state.outgoingNumbers
      .where(
        (item) =>
            item.valueOrEmpty.contains(searchTerm) ||
            item.descriptionOrEmpty.contains(searchTerm),
      )
      .toList()
      .sortedBy((element) => element.valueOrEmpty);

  @override
  void initState() {
    _textEditingController.addListener(
      () => setState(() {
        searchTerm = _textEditingController.text;
      }),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              prefixIcon: Icon(
                Icons.search,
                color: context.colors.grey1,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              hintText: context.strings.allNumbers.search.placeholder,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.close,
                  color: context.colors.grey1,
                ),
                onPressed: () {
                  if (_textEditingController.text.isEmpty) {
                    Navigator.pop(context);
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  _textEditingController.clear();
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          if (items.isNotEmpty)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 600),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.grey3),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4).copyWith(
                      right: 12,
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: ClampingScrollPhysics(),
                      itemCount: items.length,
                      shrinkWrap: true,
                      itemBuilder: (_, index) => OutgoingNumberItem(
                        item: items[index],
                        onOutgoingNumberSelected:
                            widget.onOutgoingNumberSelected,
                        active: widget.state.isActive(items[index]),
                        highlight: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// This is a button that we're faking to look like a dropdown item, as it opens
/// a custom dialog but behaviours in a similar way to a dropdown.
class _ButtonStylizedAsDropdown extends StatelessWidget {
  const _ButtonStylizedAsDropdown({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.strings.allNumbers.placeholder,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            FaIcon(
              FontAwesomeIcons.chevronDown,
              size: 16,
              color: context.colors.grey6,
            ),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      onPressed: onPressed,
    );
  }
}

extension on BuildContext {
  PromptOutgoingCLIMainMessages get strings => msg.main.outgoingCLI.prompt;
}

extension on OutgoingNumberSelectorState {
  bool isActive(OutgoingNumber other) => this.currentOutgoingNumber == other;
}
