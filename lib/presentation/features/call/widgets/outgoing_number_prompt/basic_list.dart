import 'package:flutter/material.dart';
import 'package:vialer/presentation/resources/localizations.dart';

import '../../../../../data/models/outgoing_number_prompt/outgoing_number_selection.dart';
import '../../../../resources/messages.i18n.dart';
import 'heading.dart';
import 'widget.dart';

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
