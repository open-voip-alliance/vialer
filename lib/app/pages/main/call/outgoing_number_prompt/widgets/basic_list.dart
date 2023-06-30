import 'package:flutter/material.dart';

import '../../../../../resources/localizations.dart';
import '../../../../../resources/messages.i18n.dart';
import '../outgoing_number_selection.dart';
import '../widget.dart';
import 'heading.dart';

class BasicList extends StatelessWidget {
  const BasicList(
    this.state, {
    required this.onOutgoingNumberSelected,
  });

  final OutgoingNumberSelectorState state;
  final OutgoingNumberSelectedCallback onOutgoingNumberSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Subheading(context.strings.allNumbers.label),
        ...state.outgoingNumbers
            .where((item) => item != state.currentOutgoingNumber)
            .take(4)
            .toWidgets(onOutgoingNumberSelected, state.currentOutgoingNumber),
      ],
    );
  }
}

extension on BuildContext {
  PromptOutgoingCLIMainMessages get strings => msg.main.outgoingCLI.prompt;
}
